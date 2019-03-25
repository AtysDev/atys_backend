defmodule Auth.Routes.Register do
  alias Plug.Conn
  alias Auth.User
  alias Auth.Email
  alias Atys.Plugs.SideUnchanneler
  use Plug.Builder

  plug(SideUnchanneler, send_after_ms: 500)
  plug :create
  plug(SideUnchanneler, execute: true)

  def create(%Conn{path_info: ["register"], method: "POST"} = conn, _opts) do
    with {:ok, {email, password}} <- get_values(conn.body_params),
         :ok <- create_and_send_email(email: email, password: password) do
      Conn.resp(conn, 200, "check_email")
    else
      {:error, :missing_email_or_password} ->
        Conn.resp(conn, 400, "Missing email or password")

      _ ->
        Conn.resp(conn, 500, "Internal error")
    end
  end
  def create(conn, _opts), do: conn

  defp create_and_send_email(email: email, password: password) do
    case User.create(email: email, password: password) do
      {:ok, user_id} -> Email.confirm_email_address(email: email, id: user_id)
      {:error, :email_already_exists} -> Email.trying_to_reregister(email)
      {:error, error} -> {:error, error}
    end
  end

  defp get_values(%{"email" => email, "password" => password}) do
    {:ok, {email, password}}
  end

  defp get_values(_), do: {:error, :missing_email_or_password}
end
