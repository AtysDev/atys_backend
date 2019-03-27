use Mix.Config

service_names = [
  :token,
  :auth
]

services =
  Enum.map(service_names, fn service_name ->
    env_name =
      "#{Atom.to_string(service_name)}_url"
      |> String.to_atom()

    env_value =
      "#{Atom.to_string(service_name)}_url"
      |> String.upcase()
      |> System.get_env()

    {env_name, env_value}
  end)

config :atys_api, services
