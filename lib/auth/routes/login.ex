defmodule Auth.Routes.Login do
  alias Plug.Conn
  alias Auth.User
  alias Atys.Plugs.SideUnchanneler
  use Plug.Builder

  plug(SideUnchanneler, send_after_ms: 500)
  plug :create
  plug(SideUnchanneler, execute: true)

  def create(%Conn{path_info: ["login"], method: "POST"} = conn, _opts) do
    with {:ok, {email, password}} <- get_values(conn.body_params),
    {:ok, user} <- User.find(email: email),
    :ok <- User.validate_password(user, password),
    :ok <- validate_confirmed(user),
    {:ok, token} <- get_login_token(user) do
      Conn.resp(conn, 200, token)
    else
      {:error, :missing_email_or_password} -> Conn.resp(conn, 400, "missing email or password")
      {:error, :email_not_found} -> Conn.resp(conn, 403, "Invalid email or password")
      {:error, :invalid_password} -> Conn.resp(conn, 403, "Invalid email or password")
      {:error, :email_not_confirmed} -> Conn.resp(conn, 403, "Email not confirmed")
      {:error, :token_unavailable_failure} -> Conn.resp(conn, 503, "Server Unavailable")
      {:error, :token_server_failure} -> Conn.resp(conn, 500, "Internal error")
      {:error, _error} -> Conn.resp(conn, 500, "Internal error")
    end
  end
  def create(conn, _opts), do: conn


  defp validate_confirmed(%User{confirmed?: true}), do: :ok
  defp validate_confirmed(_user), do: {:error, :email_not_confirmed}

  defp get_login_token(%User{id: id}) do
    token_url = Application.get_env(:auth, :token_url)
    headers = [
      {"Authorization", Application.get_env(:auth, :token_auth_header)},
      {"Content-Type", "application/x-www-form-urlencoded"},
    ]

    body = "v=" <> URI.encode_www_form("#{id}")
    case Mojito.request(:post, token_url, headers, body) do
      {:ok, %Mojito.Response{status_code: 200, body: token}} -> {:ok, token}
      {:ok, _response} -> {:error, :token_server_failure}
      {:error, _error} -> {:error, :token_unavailable_failure}
    end
  end

  defp get_values(%{"email" => email, "password" => password}) do
    {:ok, {email, password}}
  end

  defp get_values(_), do: {:error, :missing_email_or_password}
end
