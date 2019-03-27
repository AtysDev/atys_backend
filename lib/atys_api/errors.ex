defmodule AtysApi.Errors do
  @errors %{
    cannot_decode_request: 400,
    invalid_param: 400,
    cannot_encode_request: 400,
    item_not_found: 400,
    cannot_contact_server: 503,
    cannot_decode_response: 500,
    cache_full: 503
  }

  defmacro reason(name) do
    Map.fetch!(@errors, name)
    quote do
      unquote(name)
    end
  end

  def get_status_code(name), do: Map.fetch!(@errors, name)
end
