defmodule Auth.EmailProvider do
  @callback send(Keyword.t()) :: :ok | {:error, atom}
end
