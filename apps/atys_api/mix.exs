defmodule AtysApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :atys_api,
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
      env: AtysApi.Environment.get(Mix.env())
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_json_schema, "~> 0.5.8"},
      {:jason, "~> 1.1"},
      {:mint, git: "git@github.com:ericmj/mint.git", branch: "master", override: true},
      {:mojito, git: "git@github.com:anilredshift/mojito.git", branch: "master"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
