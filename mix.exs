defmodule PlugMachineToken.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_machine_token,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:jose, "~> 1.9"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
