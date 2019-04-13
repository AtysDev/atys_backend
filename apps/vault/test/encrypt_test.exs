defmodule VaultEncryptTest do
  alias AtysApi.Service.{Project, Token}
  use ExUnit.Case
  use Plug.Test

  @key <<1::256>> |> Base.url_encode64()
  @machine_key <<2::256>> |> Base.url_encode64()
  @create_token_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww"

  setup_all do
    create_project()
  end

  test "successfully encrypts a key", context do
    conn = call_create(context, %{machine_key: @machine_key, payload: "hello world", extra: %{}})
    assert 200 = conn.status
    %{"data" => %{"ciphertext" => ciphertext}} = Jason.decode!(conn.resp_body)
    assert {:ok, message_serialized} = Atys.Crypto.AES.decrypt_256(@key, ciphertext)
    assert {:ok, %{plaintext: "hello world"}} = Atys.Crypto.Message.deserialize(message_serialized)
  end

  defp get_token() do
    user_id = Ecto.UUID.generate()

    {:ok, %{data: %{"token" => token}}} =
      Token.create_token(%{auth_header: @create_token_header, request_id: "123", user_id: user_id})

    token
  end

  defp create_project() do
    url = "http://localhost:#{AtysApi.Environment.get_port(:project_api)}/"

    opts = [
      method: :post,
      data: %{
        token: get_token(),
        name: "my_cool_project",
        key: @key,
        machine_key: @machine_key
      }
    ]

    {:ok,
     %AtysApi.Response{
       data: %{
         "machine_key_id" => machine_key_id,
         "project_id" => project_id
       },
       request_id: "123",
       status_code: 200
     }} = AtysApi.Request.send(url, "123", opts)

    %{project_id: project_id, machine_key_id: machine_key_id}
  end

  defp call_create(%{project_id: project_id, machine_key_id: machine_key_id}, %{machine_key: machine_key, payload: payload, extra: extra}) do
    data = %{
      project_id: project_id,
      machine_key_id: machine_key_id,
      machine_key: machine_key,
      payload: payload,
      extra: extra
    }

    conn(:post, "/encrypt", Jason.encode!(%{data: data}))
    |> put_req_header("content-type", "application/json")
    |> Vault.call(Vault.init([]))
  end
end
