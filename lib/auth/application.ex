defmodule Auth.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Postgrex, [{:name, :db} | Application.get_env(:auth, :db_conn)]}
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
