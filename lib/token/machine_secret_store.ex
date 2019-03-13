defmodule Token.MachineSecretStore do
  def get(machine_name) do
    Application.get_env(:token, :machine_secrets)
    |> Map.fetch(machine_name)
    |> case do
      :error -> {:error, :invalid_issuer_name}
      {:ok, value} -> {:ok, value}
    end
  end
end
