defmodule AtysApi.Error do
  @enforce_keys [:reason, :request_id]
  defstruct reason: nil, data: %{}, status_code: nil, request_id: nil
end
