use Mix.Config

ports = %{
  token: 4000,
  auth: 4001,
}

services = Enum.map(ports, fn {service_name, port} ->
  env_name = "#{Atom.to_string(service_name)}_url"
  |> String.to_atom()
  {env_name, "http://localhost:#{port}"}
end)

config :atys_api, services
