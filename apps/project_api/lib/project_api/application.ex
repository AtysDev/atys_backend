defmodule ProjectApi.Application do
  @moduledoc false
  alias AtysApi.Environment
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: ProjectApi, options: [port: Environment.get_port(:project_api)])
    ]
    opts = [strategy: :one_for_one, name: ProjectApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
