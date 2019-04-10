defmodule ProjectApiCreateTest do
  alias AtysApi.Response
  alias AtysApi.Service.{Project, Secret, Token}
  use ExUnit.Case
  use Plug.Test

  @create_token_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww"
  @is_authorized_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzZWNyZXQifQ.QgWPtWPFbdPZBlku39JpzzHzLD4kBHNh4dWVrr9d-JM"
  @get_machine_key_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2YXVsdCJ9.UAeEJ70l5YfyZ_4z_Qi4oD0U1En2ZdRZiKlEWsSUlRs"
  @key <<1::256>> |> Base.url_encode64()
  @machine_key <<2::256>> |> Base.url_encode64()

  test "creates a new project" do
    {_user_id, token} = create_user()
    conn = call_create(%{token: token, key: @key, machine_key: @machine_key, name: "my project"})
    assert 200 = conn.status

    assert %{"data" => %{"machine_key_id" => machine_id, "project_id" => project_id}} =
             Jason.decode!(conn.resp_body)

    assert {:ok, _resp} =
             Project.can_access(%{
               auth_header: @is_authorized_header,
               request_id: "234",
               token: token,
               id: project_id
             })

    assert {:ok, %Response{data: %{"key" => encrypted_machine_key, "project_id" => ^project_id}}} =
             Secret.get_machine_key(%{
               auth_header: @get_machine_key_header,
               request_id: "345",
               id: machine_id
             })

    assert {:ok, @key} = Atys.Crypto.AES.decrypt_256(@machine_key, encrypted_machine_key)
  end

  defp create_user() do
    user_id = Ecto.UUID.generate()

    {:ok, %{data: %{"token" => token}}} =
      Token.create_token(%{auth_header: @create_token_header, request_id: "123", user_id: user_id})

    {user_id, token}
  end

  defp call_create(data) do
    conn(:post, "/", Jason.encode!(%{data: data}))
    |> put_req_header("content-type", "application/json")
    |> ProjectApi.call(ProjectApi.init([]))
  end
end
