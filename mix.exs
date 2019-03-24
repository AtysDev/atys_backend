defmodule Auth.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth,
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
      mod: {Auth.Application, []}
    ]
  end

  defp deps do
    [
      {:cors_plug, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.14.1"},
      {:sider, "~> 0.1.0"}
    ]
  end
end
