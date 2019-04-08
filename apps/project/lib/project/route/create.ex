defmodule Project.Route.Create do
  alias Plug.Conn
  alias Project.{AuthHelper, Repo}
  alias Project.Schema.Project
  alias AtysApi.{Errors, Responder}
  use Plug.Builder
  require Errors

  plug(:create)

  @create_schema %{
                   "type" => "object",
                   "properties" => %{
                     "token" => %{
                       "type" => "string"
                     },
                     "name" => %{
                       "type" => "string"
                     }
                   },
                   "required" => ["token", "name"]
                 }
                 |> ExJsonSchema.Schema.resolve()

  def create(%Conn{path_info: [], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{meta: %{"request_id" => request_id}, data: %{"token" => token} = data}} <-
           Responder.get_values(conn, @create_schema),
         {:ok, user_id} <- AuthHelper.validate_token(token, request_id: request_id),
         {:ok, project_id} <- insert_project(user_id, data) do
      Responder.respond(conn, data: %{id: project_id})
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp insert_project(user_id, data) do
    Ecto.Changeset.change(%Project{}, %{user_id: user_id})
    |> Project.changeset(data)
    |> Repo.insert()
    |> case do
      {:ok, %{id: project_id}} -> {:ok, project_id}
      {:error, changeset} -> {:error, AtysApi.Errors.unexpected(changeset)}
    end
  end
end
