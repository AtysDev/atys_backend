defmodule Auth.Routes.Login do
  alias Plug.Conn
  alias Auth.User

  def create(conn) do
    with {:ok, {email, password}} <- get_values(conn.body_params),
    {:ok, user} <- User.find(email: email),
    :ok <- User.validate_password(user, password) do
      Conn.send_resp(conn, 200, "TODO SEND TOKEN")
    else
      {:error, :missing_email_or_password} -> Conn.send_resp(conn, 400, "missing email or password")
      {:error, :email_not_found} -> Conn.send_resp(conn, 403, "Invalid email or password")
      {:error, :invalid_password} -> Conn.send_resp(conn, 403, "Invalid email or password")
      {:error, _error} -> Conn.send_resp(conn, 500, "Internal error")
    end
  end

  defp get_values(%{"email" => email, "password" => password}) do
    {:ok, {email, password}}
  end

  defp get_values(_), do: {:error, :missing_email_or_password}
end
