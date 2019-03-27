defmodule AtysApi.Request do
  defstruct meta: {}, data: {}

  require AtysApi.Errors
  alias AtysApi.{Errors, Request}

  def send(url, request_id, opts \\ []) do
    data = Keyword.get(opts, :data, %{})

    request = %Request{
      meta: %{
        request_id: request_id
      },
      data: data
    }

    response =
      case Keyword.get(opts, :method, :get) do
        :get -> get(url, request, opts)
        :post -> post(url, request, opts)
      end

    AtysApi.Logger.log_response(url: url, response: response, opts: opts)
    response
  end

  defp get(url, %{meta: %{request_id: request_id}} = request, opts) do
    with {:ok, encoded} <- encode(request),
         url <- "#{url}?#{URI.encode_query(r: encoded)}" do
      make_request(url, request_id, "", opts)
    end
  end

  defp post(url, %{meta: %{request_id: request_id}} = request, opts) do
    with {:ok, encoded} <- encode(request) do
      make_request(url, request_id, encoded, opts)
    end
  end

  defp encode(%{meta: %{request_id: request_id}} = request) do
    case Jason.encode(request) do
      {:ok, encoded} ->
        {:ok, encoded}

      _error ->
        {:error,
         %AtysApi.Error{
           reason: Errors.reason(:cannot_encode_request),
           request_id: request_id
         }}
    end
  end

  defp make_request(url, request_id, body, opts) do
    headers =
      Keyword.get(opts, :headers, [])
      |> Mojito.Headers.put("Content-Type", "application/json; charset=utf-8")

    method = Keyword.get(opts, :method, :get)

    case Mojito.request(method, url, headers, body) do
      {:ok, %Mojito.Response{} = response} ->
        parse_response(response, request_id)

      {:error, %Mojito.Error{reason: reason, message: message}} ->
        {:error,
         %AtysApi.Error{
           reason: Errors.reason(:cannot_contact_server),
           data: %{reason: reason, message: message},
           request_id: request_id
         }}
    end
  end

  defp parse_response(%Mojito.Response{status_code: status_code, body: body}, request_id) do
    case Jason.decode(body) do
      {:ok, %{"status" => "ok", "data" => data}} ->
        {:ok,
         %AtysApi.Response{
           status_code: status_code,
           request_id: request_id,
           data: data
         }}

      {:ok, %{"status" => "error", "reason" => reason, "data" => data}} ->
        {:error,
         %AtysApi.Error{
           status_code: status_code,
           request_id: request_id,
           reason: reason,
           data: data
         }}

      {:error, _error} ->
        {:error,
         %AtysApi.Error{
           status_code: status_code,
           request_id: request_id,
           reason: Errors.reason(:cannot_decode_response)
         }}
    end
  end
end
