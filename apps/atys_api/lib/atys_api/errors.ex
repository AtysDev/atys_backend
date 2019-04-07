defmodule AtysApi.Errors do
  @errors %{
    cannot_decode_request: 400,
    invalid_param: 400,
    cannot_encode_request: 400,
    item_already_exists: 400,
    unauthorized: 403,
    email_not_confirmed: 403,
    item_not_found: 404,
    locked_out: 423,
    unexpected: 500,
    cannot_decode_response: 500,
    cannot_contact_server: 503,
    cache_full: 503
  }

  defmacro reason(name) when is_atom(name) do
    Map.fetch!(@errors, name)

    quote do
      unquote(name)
    end
  end

  defmacro reason(name) do
    quote bind_quoted: [name: name] do
      # Used as a side effect to validate the name
      AtysApi.Errors.get_status_code(name)
      name
    end
  end

  def unexpected(underlying_error) do
    AtysApi.Logger.log_unexpected(underlying_error)
    reason(:unexpected)
  end

  def get_status_code(name), do: Map.fetch!(@errors, name)
end
