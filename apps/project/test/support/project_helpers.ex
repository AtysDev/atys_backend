defmodule Project.TestSupport.ProjectHelpers do
  alias AtysApi.Service.Token
  use Plug.Test

  @create_token_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww"
  @create_project_header "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0X2FwaSJ9.v8suXLqJ5Vm6eXddObCZc2izMrF_hxbSTQiHObKZpaM"

  def create_user() do
    user_id = Ecto.UUID.generate()

    {:ok, %{data: %{"token" => token}}} =
      Token.create_token(%{auth_header: @create_token_header, request_id: "123", user_id: user_id})

    {user_id, token}
  end

  def create_project(token) do
    data = %{token: token}
    conn = conn(:post, "/", Jason.encode!(%{meta: %{request_id: "123"}, data: data}))
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", @create_project_header)
    |> Project.call(Project.init([]))

    %{"data" => %{"id" => id}} = Jason.decode!(conn.resp_body)
    id
  end
end
