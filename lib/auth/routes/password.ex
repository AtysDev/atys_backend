defmodule Auth.Routes.Password do
  alias Plug.Conn
  alias Auth.Email
  alias Auth.User
  alias Atys.Plugs.SideUnchanneler
  use Plug.Builder

  plug(SideUnchanneler, send_after_ms: 50)
  plug(:start_reset)
  plug(SideUnchanneler, execute: true)

  plug(SideUnchanneler, send_after_ms: 500)
  plug(:reset)
  plug(SideUnchanneler, execute: true)

  def start_reset(%Conn{path_info: ["password", "reset"], method: "GET"} = conn, _opts) do
    with {:ok, email} <- get_email(conn.query_params),
         :ok <- send_reset_email_if_valid(email) do
      Conn.resp(conn, 200, "check_email")
    else
      {:error, :missing_email} -> Conn.resp(conn, 400, "Missing email or password")
      {:error, _error} -> Conn.resp(conn, 500, "Internal error")
    end
  end
  def start_reset(conn, _opts), do: conn

  def reset(%Conn{path_info: ["password", "reset"], method: "POST"} = conn, _opts) do
    with {:ok, {token, new_password}} <- get_values(conn.body_params),
    {:ok, id} <- validate_token(token),
    :ok <- User.update_password(id, new_password) do
      Sider.remove(:email_tokens, token)
      Conn.resp(conn, 200, "password reset")
    else
      {:error, :missing_token_or_password} -> Conn.resp(conn, 400, "Missing token or password")
      {:error, :invalid_token} -> Conn.resp(conn, 403, "invalid token")
      {:error, _error} -> Conn.resp(conn, 500, "Internal error")
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
      {:error, :missing_key} -> {:error, :invalid_token}
    end
  end

  defp get_email(%{"email" => email}), do: {:ok, email}
  defp get_email(_), do: {:error, :missing_email}

  defp get_values(%{"token" => token, "password" => password}) do
    {:ok, {token, password}}
  end
  defp get_values(_), do: {:error, :missing_token_or_password}
end
