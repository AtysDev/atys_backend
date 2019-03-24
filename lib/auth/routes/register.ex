defmodule Auth.Routes.Register do
  alias Plug.Conn
  alias Auth.User
  alias Auth.Email

  def create(conn) do
    with {:ok, {email, password}} <- get_values(conn.body_params),
         :ok <- create_and_send_email(email: email, password: password) do
      Conn.send_resp(conn, 200, "check_email")
    else
      {:error, :missing_email_or_password} ->
        Conn.send_resp(conn, 400, "Missing email or password")

      _ ->
        Conn.send_resp(conn, 500, "Internal error")
    end
  end

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
