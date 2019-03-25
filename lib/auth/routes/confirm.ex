defmodule Auth.Routes.Confirm do
  alias Plug.Conn
  alias Auth.User
  alias Atys.Plugs.SideUnchanneler
  use Plug.Builder

  plug(SideUnchanneler, send_after_ms: 50)
  plug(:create)
  plug(SideUnchanneler, execute: true)

  def create(%Conn{path_info: ["confirm"], method: "POST"} = conn, _opts) do
    with {:ok, token} <- get_token(conn.body_params),
         {:ok, id} <- validate_token(token),
         :ok <- User.confirm_email(id) do
      Sider.remove(:email_tokens, token)
      Conn.resp(conn, 200, "email confirmed")
    else
      {:error, :missing_token} -> Conn.resp(conn, 400, "missing token")
      {:error, :invalid_token} -> Conn.resp(conn, 403, "invalid token")
      {:error, _error} -> Conn.resp(conn, 500, "Internal error")
    end
  end

  def create(conn, _opts), do: conn

  defp validate_token(token) do
    case Sider.get(:email_tokens, token) do
      {:ok, id} -> {:ok, id}
      {:error, :missing_key} -> {:error, :invalid_token}
    end
  end

  defp get_token(%{"token" => token}), do: {:ok, token}
  defp get_token(_query_params), do: {:error, :missing_token}
end
