defmodule PlugMachineTokenTest do
  alias JOSE.{JWK, JWS, JWT}
  alias Plug.Conn
  use ExUnit.Case, async: true
  use Plug.Test

  @key <<1::256>>

  def key_callback("my_service"), do: {:ok, @key}

  test "Passes without affecting the conn when the machine key is valid" do
    auth_header = create_auth_header("my_service", @key)
    conn = create_conn(auth_header)
    assert ^conn = call_plug(conn, &key_callback/1)
  end

  test "halts if the authorization is missing" do
    conn = conn(:get, "/") |> call_plug(&key_callback/1)
    assert_halted(conn, "missing_authorization_header")
  end

  test "halts if multiple authorization headers" do
    auth_header = create_auth_header("my_service", @key)
    conn = create_conn(auth_header)
    req_header = conn.req_headers |> List.first()
    req_headers = List.duplicate(req_header, 2)
    conn = %Conn{conn | req_headers: req_headers}
      |> call_plug(&key_callback/1)

    assert_halted(conn, "too_many_authorization_headers")
  end

  test "halts if basic auth is used" do
     conn = create_conn("Basic 123")
      |> call_plug(&key_callback/1)
    assert_halted(conn, "authorization_header_not_bearer")
  end

  test "halts if the authorization is not a JWT header" do
    conn = create_conn("Bearer not_a_jwt")
      |> call_plug(&key_callback/1)

    assert_halted(conn, "invalid_authorization_header")
  end

  test "halts if the authorization is missing the issuer field" do
    jwk = JWK.from_oct(@key)
    body = %{"oops" => "no issuer"}
    jwt = JWT.sign(jwk, %{ "alg" => "HS256" }, body)
    |> JWS.compact
    |> elem(1)
    token = "Bearer " <> jwt

    conn = create_conn(token)
      |> call_plug(&key_callback/1)

    assert_halted(conn, "invalid_authorization_header")
  end

  test "halts if the issuer_secret cannot be found" do
    callback = fn _ -> {:error, :not_found} end
    auth_header = create_auth_header("my_service", @key)
    conn = create_conn(auth_header)
      |> call_plug(callback)
    assert_halted(conn, "not_found")
  end

  test "halt if the issuer_secret isn't 256 bits" do
    callback = fn _ -> {:ok, <<1::128>>} end
    auth_header = create_auth_header("my_service", @key)
    conn = create_conn(auth_header)
      |> call_plug(callback)
    assert 500 = conn.status
    assert "invalid_issuer_secret" = conn.resp_body
    assert true = conn.halted
  end

  test "halts if the signature is invalid" do
    wrong_key = <<0::256>>
    callback = fn "my_service" -> {:ok, wrong_key} end
    auth_header = create_auth_header("my_service", @key)
    conn = create_conn(auth_header)
    conn = call_plug(conn, callback)
    assert_halted(conn, "bad_signature")
  end


  defp create_conn(auth_header) do
    conn(:get, "/")
    |> put_req_header("authorization", auth_header)
  end

  defp call_plug(conn, callback) do
    opts = PlugMachineToken.init(get_issuer_secret: callback)
    PlugMachineToken.call(conn, opts)
  end

  defp create_auth_header(issuer, secret) do
    jwk = JWK.from_oct(secret)
    body = %{"iss" => issuer}

    token = JWT.sign(jwk, %{ "alg" => "HS256" }, body)
    |> JWS.compact
    |> elem(1)

    "Bearer " <> token
  end

  defp assert_halted(conn, status) do
    assert 403 = conn.status
    assert ^status = conn.resp_body
    assert true = conn.halted
  end
end
