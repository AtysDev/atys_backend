defmodule Token.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Sider, %{capacity: 100, name: :token_cache}},
      Plug.Cowboy.child_spec(scheme: :http, plug: Token, options: [port: 4000])
    ]

    opts = [strategy: :one_for_one, name: Token.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
