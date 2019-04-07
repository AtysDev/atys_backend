defmodule Project do
  @moduledoc false
  alias Plug.Conn
  alias Project.Route
  use Plug.Builder

  plug(CORSPlug)
  plug(AtysApi.PlugJson)
  plug(Plug.RequestId)
  plug(Route.Create)
  plug(:missing)

  def missing(%Conn{state: state} = conn, _opts) when state == :unset do
    Conn.resp(conn, 404, "not found")
  end

  def missing(conn, _opts), do: conn
end
