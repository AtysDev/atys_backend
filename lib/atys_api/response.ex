defmodule AtysApi.Response do
  @enforce_keys [:status_code, :request_id]
  defstruct status_code: nil, request_id: nil, data: %{}
end
