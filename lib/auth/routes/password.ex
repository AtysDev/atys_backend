defmodule Auth.Routes.Password do
  alias Plug.Conn
  alias Auth.Email
  alias Auth.User
  alias Atys.Plugs.SideUnchanneler
  alias AtysApi.{Errors, Responder}
  use Plug.Builder
  require Errors

  plug(SideUnchanneler, send_after_ms: 50)
  plug(:start_reset)
  plug(SideUnchanneler, execute: true)

  plug(SideUnchanneler, send_after_ms: 500)
  plug(:reset)
  plug(SideUnchanneler, execute: true)

  @start_reset_schema %{
                        "type" => "object",
                        "properties" => %{
                          "email" => %{
                            "type" => "string"
                          }
                        },
                        "required" => ["email"]
                      }
                      |> ExJsonSchema.Schema.resolve()

  @reset_schema %{
                  "type" => "object",
                  "properties" => %{
                    "token" => %{
                      "type" => "string"
                    },
                    "password" => %{
                      "type" => "string"
                    }
                  },
                  "required" => ["token", "password"]
                }
                |> ExJsonSchema.Schema.resolve()

  def start_reset(%Conn{path_info: ["password", "reset"], method: "GET"} = conn, _opts) do
    with {:ok, conn, %{data: %{"email" => email}}} <-
           Responder.get_values(conn, @start_reset_schema),
         :ok <- send_reset_email_if_valid(email) do
      Responder.respond(conn)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def start_reset(conn, _opts), do: conn

  def reset(%Conn{path_info: ["password", "reset"], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: %{"token" => token, "password" => new_password}}} <-
           Responder.get_values(conn, @reset_schema),
         {:ok, id} <- validate_token(token),
         :ok <- User.update_password(id, new_password) do
      Sider.remove(:email_tokens, token)
      Responder.respond(conn)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def reset(conn, _opts), do: conn

  defp send_reset_email_if_valid(email) do
    case User.find(email: email) do
      {:ok, %User{id: id}} -> Email.reset_password(email: email, id: id)
      _ -> :ok
    end
  end

  defp validate_token(token) do
    case Sider.get(:email_tokens, token) do
      {:ok, id} -> {:ok, id}
      {:error, :missing_key} -> {:error, Errors.reason(:unauthorized)}
    end
  end
end
