defmodule Auth do
  @moduledoc false
  use Plug.Router
  alias Auth.Routes
  alias Atys.Plugs.SideUnchanneler

  plug(CORSPlug)

  plug(SideUnchanneler, send_after_ms: 400)
  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:dispatch)
  plug(SideUnchanneler, execute: true)

  post "/register" do
    Routes.Register.create(conn)
  end

  post "/confirm" do
    Routes.Confirm.create(conn)
  end

  post "/login" do
    Routes.Login.create(conn)
  end

  match _ do
    Plug.Conn.resp(conn, 404, "not found")
  end
end
