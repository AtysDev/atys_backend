defmodule Secret.MixProject do
  use Mix.Project

  def project do
    [
      app: :secret,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Secret.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:atys_api, in_umbrella: true, env: Mix.env()},
      {:cors_plug, "~> 2.0"},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_machine_token, in_umbrella: true, env: Mix.env()},
      {:postgrex, "~> 0.14.1"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
