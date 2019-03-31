defmodule Auth.Routes.Login do
  alias AtysApi.{Errors, Response, Responder}
  alias AtysApi.Service.Token
  alias Plug.Conn
  alias Auth.User
  alias Atys.Plugs.SideUnchanneler
  use Plug.Builder
  require Errors

  plug(SideUnchanneler, send_after_ms: 500)
  plug(:create)
  plug(SideUnchanneler, execute: true)

  @login_schema %{
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

  def create(%Conn{path_info: ["login"], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: %{"email" => email, "password" => password}}} <-
           Responder.get_values(conn, @login_schema, frontend_request: true),
         {:ok, user} <- get_valid_user(email: email, password: password),
         {:ok, %Response{data: %{"token" => token}}} <- get_login_token(conn, user) do
      Responder.respond(conn, data: %{token: token})
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp validate_confirmed(%User{confirmed: true}), do: :ok
  defp validate_confirmed(_user), do: {:error, Errors.reason(:email_not_confirmed)}

  defp get_login_token(conn, %User{id: id}) do
    auth_header = Application.get_env(:auth, :token_auth_header)
    [request_id] = Conn.get_resp_header(conn, "x-request-id")

    Token.create_token(%{auth_header: auth_header, request_id: request_id, user_id: id})
  end

  defp get_valid_user(email: email, password: password) do
    with {:ok, user} <- User.get_by_email(email),
         :ok <- User.validate_password(user, password),
         :ok <- validate_confirmed(user) do
      {:ok, user}
    else
      {:error, Errors.reason(:item_not_found)} -> {:error, Errors.reason(:item_not_found)}
      error -> error
    end
  end
end
