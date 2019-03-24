defmodule Token.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Application.get_env(:token, :machine_secrets_json)
    |> Token.SecretsParser.parse()
    |> case do
      {:ok, secrets} -> start_server(secrets)
      {:error, reason} -> {:error, reason}
    end
  end

  defp start_server(secrets) do
    Application.put_env(:token, :machine_secrets, secrets)
    children = [
      {Sider, %{capacity: 10000, name: :token_cache}},
      Plug.Cowboy.child_spec(scheme: :http, plug: Token, options: [port: 4000])
    ]

    opts = [strategy: :one_for_one, name: Token.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
