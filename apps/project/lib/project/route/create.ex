defmodule Project.Route.Create do
  alias Plug.Conn
  alias Project.Repo
  alias Project.Schema.Project
  alias AtysApi.{Errors, Responder, Response}
  alias AtysApi.Service.Token
  use Plug.Builder
  require Errors

  plug(:create)

  @create_schema %{
                   "type" => "object",
                   "properties" => %{
                     "token" => %{
                       "type" => "string"
                     }
                   },
                   "required" => ["token"]
                 }
                 |> ExJsonSchema.Schema.resolve()

  def create(%Conn{path_info: [], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: %{"token" => token}}} <-
           Responder.get_values(conn, @create_schema, frontend_request: true),
         {:ok, user_id} <- validate_token(conn, token),
         {:ok, project_id} <- insert_project(user_id) do
      Responder.respond(conn, data: %{id: project_id})
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp validate_token(conn, token) do
    auth_header = Application.get_env(:project, :token_auth_header)
    [request_id] = Conn.get_resp_header(conn, "x-request-id")

    Token.get_user_id(%{auth_header: auth_header, request_id: request_id, token: token})
    |> case do
      {:ok, %Response{data: %{"user_id" => user_id}}} -> {:ok, user_id}
      {:ok, response} -> {:error, Errors.unexpected(response)}
      {:error, response} -> {:error, response}
    end
  end

  defp insert_project(user_id) do
    Project.changeset(%Project{}, %{user_id: user_id})
    |> Repo.insert()
    |> case do
      {:ok, %{id: project_id}} -> {:ok, project_id}
      {:error, changeset} -> {:error, AtysApi.Errors.unexpected(changeset)}
    end
  end
end
