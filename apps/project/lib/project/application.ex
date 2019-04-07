defmodule Project.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Application.get_env(:project, :machine_secrets_json)
    |> PlugMachineToken.SecretsParser.parse()
    |> case do
      {:ok, secrets} -> start_server(secrets)
      {:error, reason} -> {:error, reason}
    end
  end

  defp start_server(secrets) do
    Application.put_env(:project, :machine_secrets, secrets)

    children = [
      {Project.Repo, []},
      Plug.Cowboy.child_spec(scheme: :http, plug: Project, options: [port: 4003])
    ]

    opts = [strategy: :one_for_one, name: Project.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
