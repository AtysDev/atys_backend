defmodule PlugMachineToken.SecretsParser do
  alias AtysApi.Errors
  def parse(nil), do: {:error, Errors.unexpected("Secret string is nil")}
  def parse(machine_secrets_string) do
    with {:ok, %{} = secrets} <- Jason.decode(machine_secrets_string),
    nil <- Enum.find_value(secrets, &get_error/1) do
      parsed = Enum.into(secrets, %{}, fn {k, v} -> {k, Base.url_decode64!(v)} end)
      {:ok, parsed}
    else
      {:ok, json} -> {:error, Errors.unexpected("secret string #{inspect(json)} is not a map")}
      {:error, error} -> {:error, Errors.unexpected({"secret string cannot be decoded", error})}
    end
  end

  defp get_error({name, encoded_value}) do
    case Base.url_decode64(encoded_value) do
      {:ok, <<_rest::size(256)>>} -> nil
      {:ok, key} -> {:error, Errors.unexpected("Secret key #{name} has the wrong length of #{bit_size(key)}")}
      _ -> {:error, Errors.unexpected("Secret key #{name} is not url_base64 encoded")}
    end
  end
end
