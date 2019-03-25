defmodule Auth do
  @moduledoc false
  alias Plug.Conn
  alias Auth.Routes
  use Plug.Builder

  plug(CORSPlug)
  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Routes.Register)
  plug(Routes.Confirm)
  plug(Routes.Login)
  plug :missing

  def missing(%Conn{state: state} = conn, _opts) when state == :unset do
    Conn.resp(conn, 404, "not found")
  end
  def missing(conn, _opts), do: conn
end
