defmodule Vault.MixProject do
  use Mix.Project

  def project do
    [
      app: :vault,
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
      mod: {Vault.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:atys_api, in_umbrella: true, env: Mix.env()},
      {:atys, git: "git@github.com:AtysDev/atys.git", branch: "master"},
      {:cors_plug, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:mox, "~> 0.5.0", only: :test},
      {:plug_cowboy, "~> 2.0"},
      {:project, in_umbrella: true, only: :test, env: Mix.env()},
      {:secret, in_umbrella: true, only: :test, env: Mix.env()},
    ]
  end
end
