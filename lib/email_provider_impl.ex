defmodule Auth.MockEmailProviderImpl do
  @behaviour Auth.EmailProvider
  def send(_args) do
    # TODO implement
    :ok
  end
end
