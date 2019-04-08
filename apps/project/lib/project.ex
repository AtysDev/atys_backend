defmodule Project do
  @moduledoc false
  alias Plug.Conn
  alias Project.Route
  use Plug.Builder

  plug(CORSPlug)
  plug(PlugMachineToken, issuer: Project.MachineSecretStore)
  plug(AtysApi.PlugJson)
  plug(Route.Create)
  plug(Route.Authorized)
  plug(:missing)

  def missing(%Conn{state: state} = conn, _opts) when state == :unset do
    Conn.resp(conn, 404, "not found")
  end

  def missing(conn, _opts), do: conn
end
