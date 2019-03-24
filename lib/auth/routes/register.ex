defmodule Auth.Routes.Register do
  alias Plug.Conn
  alias Auth.User

  def create(conn) do
    with {:ok, {email, password}} <- get_values(conn.body_params),
      {:ok, _result} <- User.create(email: email, password: password) do
      Conn.send_resp(conn, 200, "user_created")
    else
      _ -> Conn.send_resp(conn, 500, "Internal error")
    end
  end

  defp get_values(%{"email" => email, "password" => password}) do
    {:ok, {email, password}}
  end

  defp get_values(_), do: {:error, :missing_email_or_password}
end
