defmodule Secret.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Application.get_env(:secret, :machine_secrets_json)
    |> PlugMachineToken.SecretsParser.parse()
    |> case do
      {:ok, secrets} -> start_server(secrets)
      {:error, reason} -> {:error, reason}
    end
  end

  defp start_server(secrets) do
    Application.put_env(:secret, :machine_secrets, secrets)

    children = [
      {Secret.Repo, []},
      Plug.Cowboy.child_spec(scheme: :http, plug: Secret, options: [port: 4002])
    ]

    opts = [strategy: :one_for_one, name: Secret.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
