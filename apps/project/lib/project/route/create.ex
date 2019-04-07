defmodule Project.Route.Create do
  alias Plug.Conn
  alias Project.{AuthHelper, Repo}
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
           Responder.get_values(conn, @create_schema),
         {:ok, user_id} <- AuthHelper.validate_token(conn, token),
         {:ok, project_id} <- insert_project(user_id) do
      Responder.respond(conn, data: %{id: project_id})
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp insert_project(user_id) do
    Project.changeset(%Project{}, %{user_id: user_id})
    |> Repo.insert()
    |> case do
      {:ok, %{id: project_id}} -> {:ok, project_id}
      {:error, changeset} -> {:error, AtysApi.Errors.unexpected(changeset)}
    end
  end
end
