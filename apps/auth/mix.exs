defmodule Auth.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Auth.Application, []}
    ]
  end

  defp deps do
    [
      {:atys_api, in_umbrella: true, env: Mix.env()},
      {:atys, git: "git@github.com:AtysDev/atys.git", branch: "master"},
      {:cors_plug, "~> 2.0"},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:jason, "~> 1.1"},
      {:modglobal, "~> 0.2.4", only: :test},
      {:mox, "~> 0.5.0", only: :test},
      {:pbkdf2_elixir, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.14.1"},
      {:sider, "~> 0.1.0"},
      {:token, in_umbrella: true, only: :test, env: Mix.env()}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
