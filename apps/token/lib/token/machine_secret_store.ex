defmodule Token.MachineSecretStore do
  @behaviour PlugMachineToken.Issuer

  @impl true
  def get_issuers_paths() do
    %{
      "auth" => [{"POST", []}],
      "project" => [{"GET", [:wildcard]}]
    }
  end

  @impl true
  def get_secret(service) do
    Application.get_env(:token, :machine_secrets)
    |> Map.fetch(service)
    |> case do
      :error -> {:error, :invalid_issuer_name}
      {:ok, value} -> {:ok, value}
    end
  end
end
