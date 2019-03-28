defmodule Auth.Routes.Register do
  alias Plug.Conn
  alias Auth.User
  alias Auth.Email
  alias Atys.Plugs.SideUnchanneler
  alias AtysApi.{Errors, Responder}
  use Plug.Builder
  require Errors

  plug(SideUnchanneler, send_after_ms: 500)
  plug(:create)
  plug(SideUnchanneler, execute: true)

  @register_schema %{
                     "type" => "object",
                     "properties" => %{
                       "email" => %{
                         "type" => "string"
                       },
                       "password" => %{
                         "type" => "string"
                       }
                     },
                     "required" => ["email", "password"]
                   }
                   |> ExJsonSchema.Schema.resolve()

  def create(%Conn{path_info: ["register"], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: %{"email" => email, "password" => password}}} <-
           Responder.get_values(conn, @register_schema),
         :ok <- create_and_send_email(email: email, password: password) do
      Responder.respond(conn)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp create_and_send_email(email: email, password: password) do
    case User.create(email: email, password: password) do
      {:ok, user_id} -> Email.confirm_email_address(email: email, id: user_id)
      {:error, Errors.reason(:item_already_exists)} -> Email.trying_to_reregister(email)
      error -> error
    end
  end
end
