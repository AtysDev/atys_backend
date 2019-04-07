defmodule Project.Route.Authorized do
  alias Plug.Conn
  alias Project.AuthHelper
  alias AtysApi.{Errors, Responder}
  use Plug.Builder
  require Errors

  plug(:is_authorized)

  @authorized_schema %{
                       "type" => "object",
                       "properties" => %{
                         "token" => %{
                           "type" => "string"
                         }
                       },
                       "required" => ["token"]
                     }
                     |> ExJsonSchema.Schema.resolve()

  def is_authorized(%Conn{path_info: [id, "authorized"], method: "GET"} = conn, _opts) do
    with {:ok, conn, %{data: %{"token" => token}}} <-
           Responder.get_values(conn, @authorized_schema),
         {:ok, user_id} <- AuthHelper.validate_token(conn, token),
         :ok <- AuthHelper.validate_authorized(%{id: id, user_id: user_id}) do
      Responder.respond(conn)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def is_authorized(conn, _opts), do: conn
end
