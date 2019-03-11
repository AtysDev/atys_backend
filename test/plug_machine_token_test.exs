defmodule PlugMachineTokenTest do
  alias JOSE.{JWK, JWS, JWT}
  use ExUnit.Case, async: true
  use Plug.Test

  @key <<1::256>>

  test "Passes without affecting the conn when the machine key is valid" do
    callback = fn "my_service" -> {:ok, @key} end
    auth_header = create_auth_header("my_service", @key)
    conn = create_conn(auth_header)
    assert ^conn = get(conn, callback)
  end

  test "halts if the signature is invalid" do
    wrong_key = <<0::256>>
    callback = fn "my_service" -> {:ok, wrong_key} end
    auth_header = create_auth_header("my_service", @key)
    conn = create_conn(auth_header)
    conn = get(conn, callback)
    assert 403 = conn.status
    assert "bad_signature" = conn.resp_body
    assert true = conn.halted
  end

  defp create_conn(auth_header) do
    conn(:get, "/")
    |> put_req_header("authorization", auth_header)
  end

  defp get(conn, callback) do
    opts = PlugMachineToken.init(get_issuer_secret: callback)
    PlugMachineToken.call(conn, opts)
  end

  defp create_auth_header(issuer, secret) do
    jwk = JWK.from_oct(secret)
    body = %{"iss" => issuer}

    token = JWT.sign(jwk, %{ "alg" => "HS256" }, body)
    |> JWS.compact
    |> elem(1)

    "Authorization: Bearer " <> token
  end
end
