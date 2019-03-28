defmodule PlugMachineTokenTest do
  alias JOSE.{JWK, JWS, JWT}
  alias Plug.Conn
  use ExUnit.Case, async: true
  use Plug.Test

  @key <<1::256>>
  @header PlugMachineToken.create_machine_token(@key, %{name: "my_service"})

  def key_callback("my_service"), do: {:ok, @key}

  test "Passes without affecting the conn when the machine key is valid" do
    conn = create_conn(@header)
    assert ^conn = call_plug(conn, &key_callback/1)
  end

  test "Passes when an expiration date is in the future" do
    expires_at = DateTime.utc_now() |> DateTime.add(5, :second)
    header = PlugMachineToken.create_machine_token(@key, %{name: "my_service", expires_at: expires_at})
    conn = create_conn(header)
    assert ^conn = call_plug(conn, &key_callback/1)
  end

  test "halts if the authorization is missing" do
    conn = conn(:get, "/") |> call_plug(&key_callback/1)
    assert_resp(conn, "missing_authorization_header")
  end

  test "halts if multiple authorization headers" do
    conn = create_conn(@header)
    req_header = conn.req_headers |> List.first()
    req_headers = List.duplicate(req_header, 2)

    conn =
      %Conn{conn | req_headers: req_headers}
      |> call_plug(&key_callback/1)

    assert_resp(conn, "too_many_authorization_headers")
  end

  test "halts if basic auth is used" do
    conn =
      create_conn("Basic 123")
      |> call_plug(&key_callback/1)

    assert_resp(conn, "authorization_header_not_bearer")
  end

  test "halts if the authorization is not a JWT header" do
    conn =
      create_conn("Bearer not_a_jwt")
      |> call_plug(&key_callback/1)

    assert_resp(conn, "invalid_authorization_header")
  end

  test "halts if the authorization is missing the issuer field" do
    jwk = JWK.from_oct(@key)
    body = %{"oops" => "no issuer"}

    jwt =
      JWT.sign(jwk, %{"alg" => "HS256"}, body)
      |> JWS.compact()
      |> elem(1)

    token = "Bearer " <> jwt

    conn =
      create_conn(token)
      |> call_plug(&key_callback/1)

    assert_resp(conn, "invalid_authorization_header")
  end

  test "halts if the issuer_secret cannot be found" do
    callback = fn _ -> {:error, :not_found} end

    conn =
      create_conn(@header)
      |> call_plug(callback)

    assert_resp(conn, "not_found")
  end

  test "halt if the issuer_secret isn't 256 bits" do
    callback = fn _ -> {:ok, <<1::128>>} end

    conn =
      create_conn(@header)
      |> call_plug(callback)

    assert_resp(conn, "invalid_issuer_secret")
  end

  test "halts if the callback doesn't return the correct signature" do
    callback = fn _ -> @key end
    conn = create_conn(@header)
      |> call_plug(callback)
    assert_resp(conn, "invalid_issuer_callback_response")
  end

  test "halts if the signature is invalid" do
    wrong_key = <<0::256>>
    callback = fn "my_service" -> {:ok, wrong_key} end
    conn = create_conn(@header)
      |> call_plug(callback)
    assert_resp(conn, "bad_signature")
  end

  test "halts if the machine token has expired" do
    {:ok, expires_at, _} = DateTime.from_iso8601("2015-01-23T23:50:07Z")

    auth_header =
      PlugMachineToken.create_machine_token(@key, %{name: "my_service", expires_at: expires_at})

    conn = create_conn(auth_header)
      |> call_plug(&key_callback/1)
    assert_resp(conn, "bad_signature")
  end

  defp create_conn(auth_header) do
    conn(:get, "/")
    |> put_req_header("authorization", auth_header)
  end

  defp call_plug(conn, callback) do
    opts = PlugMachineToken.init(get_issuer_secret: callback)
    PlugMachineToken.call(conn, opts)
  end

  defp assert_resp(conn, details) do
    assert 403 = conn.status
    assert %{"reason" => "unauthorized", "data" => %{"details" => ^details}} = Jason.decode!(conn.resp_body)
    assert true = conn.halted
  end
end
