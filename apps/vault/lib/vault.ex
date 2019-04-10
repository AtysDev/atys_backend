defmodule Vault do
  @moduledoc false
  alias Plug.Conn
  alias Vault.Route
  use Plug.Builder

  plug(CORSPlug)
  plug(AtysApi.PlugJson)
  plug(Plug.RequestId)
  plug(Route.Encrypt)
  # plug(Route.Decrypt)
  plug(:missing)

  def missing(%Conn{state: state} = conn, _opts) when state == :unset do
    Conn.resp(conn, 404, "not found")
  end

  def missing(conn, _opts), do: conn
end
