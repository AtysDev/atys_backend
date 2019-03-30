defmodule AtysApi.PlugJson do
  use Plug.Builder

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason
  )
end
