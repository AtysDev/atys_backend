defmodule Secret.MachineSecretStore do
  @behaviour PlugMachineToken.Issuer

  @service_routes %{
    "project" => [{"POST", []},]
  }

  def get_secret(conn, service) do
    routes = Map.get(@service_routes, service, [])
    case PlugMachineToken.Issuer.is_allowed?(conn, routes) do
      true -> get_key(service)
      false -> {:error, :not_in_service_routes}
    end
  end

  defp get_key(service) do
    Application.get_env(:secret, :machine_secrets)
    |> Map.fetch(service)
    |> case do
      :error -> {:error, :invalid_issuer_name}
      {:ok, value} -> {:ok, value}
    end
  end

end
