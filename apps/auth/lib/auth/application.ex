defmodule Auth.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Postgrex, [{:name, :db} | Application.get_env(:auth, :db_conn)]},
      {Sider, %{capacity: 100_000, name: :email_tokens}},
      # Mojito.Pool.child_spec(:http_pool),
      Plug.Cowboy.child_spec(scheme: :http, plug: Auth, options: [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
