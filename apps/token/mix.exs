defmodule Token.MixProject do
  use Mix.Project

  def project do
    [
      app: :token,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Token.Application, []}
    ]
  end

  defp deps do
    [
      {:atys_api, in_umbrella: true, env: Mix.env()},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_machine_token, in_umbrella: true, env: Mix.env()},
      {:sider, "~> 0.1.0"}
    ]
  end
end
