defmodule Project.MachineSecretStore do
  @behaviour PlugMachineToken.Issuer

  @impl true
  def get_issuers_paths() do
    %{
      "vault" => [{"GET", [:wildcard]}],
      "project_api" => [{"POST", []}, {"DELETE", [:wildcard]}]
    }
  end

  @impl true
  def get_secret(service) do
    Application.get_env(:project, :machine_secrets)
    |> Map.fetch(service)
    |> case do
      :error -> {:error, :invalid_issuer_name}
      {:ok, value} -> {:ok, value}
    end
  end
end
