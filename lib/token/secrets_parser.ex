defmodule Token.SecretsParser do
  def parse(nil), do: {:error, :secrets_string_not_json}
  def parse(machine_secrets_string) do
    with {:ok, %{} = secrets} <- Jason.decode(machine_secrets_string),
    nil <- Enum.find_value(secrets, &get_error/1) do
      parsed = Enum.into(secrets, %{}, fn {k, v} -> {k, Base.url_decode64!(v)} end)
      {:ok, parsed}
    else
      {:ok, _} -> {:error, :secrets_string_not_json}
      {:error, %Jason.DecodeError{}} -> {:error, :secrets_string_not_json}
      {:error, error} -> {:error, error}
    end
  end

  defp get_error({_name, encoded_value}) do
    case Base.url_decode64(encoded_value) do
      {:ok, <<_rest::size(256)>>} -> nil
      {:ok, _} -> {:error, :incorrect_secret_size}
      _ -> {:error, :secret_not_url_base64}
    end
  end
end
