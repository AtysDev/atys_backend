defmodule AtysApi.Error do
  @derive Jason.Encoder
  @enforce_keys [:reason, :request_id]
  defstruct reason: nil, data: %{}, status_code: nil, request_id: nil, expected: false
end
