defmodule AuthorizedProjectTest do
  alias Project.TestSupport.ProjectHelpers
  alias Project.Repo
  use ExUnit.Case
  use Plug.Test

  @secret_auth_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzZWNyZXQifQ.QgWPtWPFbdPZBlku39JpzzHzLD4kBHNh4dWVrr9d-JM"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Project.Repo)
  end

  test "returns 200 when the user is authorized" do
    {_user_id, token} = ProjectHelpers.create_user()
    project_id = ProjectHelpers.create_project(token)
    conn = call_authorized(project_id, token)
    assert 200 = conn.status
  end

  test "returns 403 when the wrong token is used" do
    {_user_id, token} = ProjectHelpers.create_user()
    {_user_id, other_token} = ProjectHelpers.create_user()
    project_id = ProjectHelpers.create_project(token)
    conn = call_authorized(project_id, other_token)
    assert 403 = conn.status
  end

  test "returns 403 when the token is missing" do
    {_user_id, token} = ProjectHelpers.create_user()
    project_id = ProjectHelpers.create_project(token)
    conn = call_authorized(project_id, "wrong_token")
    assert 403 = conn.status
  end

  test "returns 400 when the project id is invalid" do
    {_user_id, token} = ProjectHelpers.create_user()
    conn = call_authorized("invalid_project_id", token)
    assert 400 = conn.status
  end

  test "returns 400 when the project id is incorrect" do
    {_user_id, token} = ProjectHelpers.create_user()
    bad_project_id = Ecto.UUID.generate()
    conn = call_authorized(bad_project_id, token)
    assert 404 = conn.status
  end

  test "returns 423 when the project is locked out" do
    {_user_id, token} = ProjectHelpers.create_user()
    project_id = ProjectHelpers.create_project(token)
    project = %Project.Schema.Project{id: project_id}

    Ecto.Changeset.change(project, %{attack_probability: 0.9})
    |> Repo.update()

    conn = call_authorized(project_id, token)
    assert 423 = conn.status
  end

  defp call_authorized(project_id, token) do
    r = %{meta: %{request_id: "123"}, data: %{token: token}} |> Jason.encode!()
    url = "/#{URI.encode(project_id)}/authorized?#{URI.encode_query(r: r)}"

    conn(:get, url)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", @secret_auth_header)
    |> Project.call(Project.init([]))
  end
end
