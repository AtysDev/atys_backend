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
      {:mint, git: "git@github.com:ericmj/mint.git", branch: "master", override: true},
      {:atys_api, in_umbrella: true, env: Mix.env()},
      {:atys, git: "git@github.com:AtysDev/atys.git", branch: "master"},
      {:cors_plug, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:mojito, "~> 0.1.0"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.14.1"},
      {:sider, "~> 0.1.0"}
    ]
  end
end
