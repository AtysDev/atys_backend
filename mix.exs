defmodule Secret.MixProject do
  use Mix.Project

  def project do
    [
      app: :secret,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
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
      {:atys_api, git: "git@github.com:AtysDev/atys_api.git", branch: "master", env: Mix.env()},
      {:cors_plug, "~> 2.0"},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_machine_token,
       git: "git@github.com:AtysDev/plug_machine_token.git", branch: "master", env: Mix.env()},
      {:postgrex, "~> 0.14.1"}
    ]
  end
end
