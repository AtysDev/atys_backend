defmodule CreateProjectTest do
  alias Project.TestSupport.ProjectHelpers
  use ExUnit.Case
  use Plug.Test

  @create_project_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0X2FwaSJ9.v8suXLqJ5Vm6eXddObCZc2izMrF_hxbSTQiHObKZpaM"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Project.Repo)
  end

  test "creates a new project" do
    {user_id, token} = ProjectHelpers.create_user()
    conn = call_create(%{token: token, name: "my new project"})
    assert 200 = conn.status
    assert %{"data" => %{"id" => id}} = Jason.decode!(conn.resp_body)

    assert %{id: ^id, user_id: ^user_id, attack_probability: 0.0} =
             Project.Repo.get(Project.Schema.Project, id)
  end

  test "403 with the wrong authorization" do
    conn =
      conn(:post, "/", Jason.encode!(%{meta: %{request_id: "123"}, data: %{}}))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer WRONG HEADER")
      |> Project.call(Project.init([]))

    assert 403 = conn.status
  end

  defp call_create(data) do
    conn(:post, "/", Jason.encode!(%{meta: %{request_id: "123"}, data: data}))
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", @create_project_header)
    |> Project.call(Project.init([]))
  end
end
