defmodule AtysApi.Environment do
  @services %{
    token: 4000,
    auth: 4001,
    secret: 4002,
    project: 4003,
    project_api: 4004
  }

  def get(:prod) do
    Enum.map(@services, fn {name, _} ->
      env_name =
        "#{Atom.to_string(name)}_url"
        |> String.to_atom()

      env_value =
        "#{Atom.to_string(name)}_url"
        |> String.upcase()
        |> System.get_env()

      if env_value == nil do
        raise "Missing environment value for #{env_name}"
      end

      {env_name, env_value}
    end)
  end

  def get(_any) do
    Enum.map(@services, fn {name, port} ->
      env_name =
        "#{Atom.to_string(name)}_url"
        |> String.to_atom()

      {env_name, "http://localhost:#{port}"}
    end)
  end

  def get_port(name), do: Map.fetch!(@services, name)
end
