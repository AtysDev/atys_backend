defmodule PlugMachineTokenTest do
  alias JOSE.{JWK, JWS, JWT}
  alias Plug.Conn
  use ExUnit.Case
  use Plug.Test

  @key <<1::256>>
  @header PlugMachineToken.create_machine_token(@key, %{name: "my_service"})
  @wrong_key_header PlugMachineToken.create_machine_token(<<2::256>>, %{name: "my_service"})
  defmodule ServiceIssuer do
    @behaviour PlugMachineToken.Issuer
    def get_secret(conn, service) do
      key = <<1::256>>
      other_key = <<22::256>>
      service_routes = %{
        "my_service" => [key: key, routes: [{"GET", []}, {"GET", ["homes", :wildcard]}, {"POST", ["homes", :wildcard, "owners"]}]],
        "car_service" => [key: other_key, routes: [{"GET", []}, {"POST", ["cars"]}]]
      }

      [key: key, routes: routes] = Map.get(service_routes, service, [key: nil, routes: []])
      case PlugMachineToken.Issuer.is_allowed?(conn, routes) do
        true -> {:ok, key}
        false -> {:error, :not_in_service_routes}
      end
    end
  end

  defmodule NotFoundIssuer do
    @behaviour PlugMachineToken.Issuer
    def get_secret(_conn, _service_name) do
      {:error, :not_found}
    end
  end

  defmodule InvalidSecretIssuer do
    @behaviour PlugMachineToken.Issuer
    def get_secret(_conn, _service_name) do
      {:ok, <<1::128>>}
    end
  end

  defmodule WrongBehaviorIssuer do
    def get_secret(_conn, _service_name), do: :ok
  end

  test "Passes without affecting the conn when the machine key is valid" do
    conn = create_conn(@header)
    assert ^conn = call_plug(conn, ServiceIssuer)
  end

  test "Passes with a wildcard route" do
    conn = conn(:get, "/homes/22")
    |> put_req_header("authorization", @header)
    assert ^conn = call_plug(conn, ServiceIssuer)
  end

  test "Passes with a wildcard route in the middle" do
    conn = conn("post", "/homes/22/owners")
    |> put_req_header("authorization", @header)
    assert ^conn = call_plug(conn, ServiceIssuer)
  end

  test "Halts when the length differs" do
    conn = conn(:get, "/homes")
    |> put_req_header("authorization", @header)
    |> call_plug(ServiceIssuer)
    assert_resp(conn, "not_in_service_routes")
  end

  test "Passes when an expiration date is in the future" do
    expires_at = DateTime.utc_now() |> DateTime.add(5, :second)
    header = PlugMachineToken.create_machine_token(@key, %{name: "my_service", expires_at: expires_at})
    conn = create_conn(header)
    assert ^conn = call_plug(conn, ServiceIssuer)
  end

  test "halts if the authorization is missing" do
    conn = conn(:get, "/") |> call_plug(ServiceIssuer)
    assert_resp(conn, "missing_authorization_header")
  end

  test "halts if multiple authorization headers" do
    conn = create_conn(@header)
    req_header = conn.req_headers |> List.first()
    req_headers = List.duplicate(req_header, 2)

    conn =
      %Conn{conn | req_headers: req_headers}
      |> call_plug(ServiceIssuer)

    assert_resp(conn, "too_many_authorization_headers")
  end

  test "halts if basic auth is used" do
    conn =
      create_conn("Basic 123")
      |> call_plug(ServiceIssuer)

    assert_resp(conn, "authorization_header_not_bearer")
  end

  test "halts if the authorization is not a JWT header" do
    conn =
      create_conn("Bearer not_a_jwt")
      |> call_plug(ServiceIssuer)

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
      |> call_plug(ServiceIssuer)

    assert_resp(conn, "invalid_authorization_header")
  end

  test "halts if the issuer_secret cannot be found" do
    conn =
      create_conn(@header)
      |> call_plug(NotFoundIssuer)

    assert_resp(conn, "not_found")
  end

  test "halt if the issuer_secret isn't 256 bits" do
    conn =
      create_conn(@header)
      |> call_plug(InvalidSecretIssuer)

    assert_resp(conn, "invalid_issuer_secret")
  end

  test "halts if the callback doesn't return the correct signature" do
    conn = create_conn(@header)
      |> call_plug(WrongBehaviorIssuer)
    assert_resp(conn, "invalid_issuer_callback_response")
  end

  test "halts if the signature is invalid" do
    conn = create_conn(@wrong_key_header)
      |> call_plug(ServiceIssuer)
    assert_resp(conn, "bad_signature")
  end

  test "halts if the machine token has expired" do
    {:ok, expires_at, _} = DateTime.from_iso8601("2015-01-23T23:50:07Z")

    auth_header =
      PlugMachineToken.create_machine_token(@key, %{name: "my_service", expires_at: expires_at})

    conn = create_conn(auth_header)
      |> call_plug(ServiceIssuer)
    assert_resp(conn, "bad_signature")
  end

  defp create_conn(auth_header) do
    conn(:get, "/")
    |> put_req_header("authorization", auth_header)
  end

  defp call_plug(conn, issuer) do
    opts = PlugMachineToken.init(issuer: issuer)
    PlugMachineToken.call(conn, opts)
  end

  defp assert_resp(conn, details) do
    assert 403 = conn.status
    assert %{"reason" => "unauthorized", "data" => %{"details" => ^details}} = Jason.decode!(conn.resp_body)
    assert true = conn.halted
  end
end
