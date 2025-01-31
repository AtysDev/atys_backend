defmodule Auth do
  @moduledoc false
  alias Plug.Conn
  alias Auth.Routes
  use Plug.Builder

  plug(CORSPlug)
  plug(AtysApi.PlugJson)
  plug(Plug.RequestId)
  plug(Routes.Register)
  plug(Routes.Confirm)
  plug(Routes.Login)
  plug(Routes.Password)
  plug(:missing)

  def missing(%Conn{state: state} = conn, _opts) when state == :unset do
    Conn.resp(conn, 404, "not found")
  end

  def missing(conn, _opts), do: conn
end
