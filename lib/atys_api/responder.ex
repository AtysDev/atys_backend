defmodule AtysApi.Responder do
  alias Plug.Conn
  require AtysApi.Errors
  alias AtysApi.Errors

  def handle_error(conn, error, opts \\ []) do
    send_response = Keyword.get(opts, :send_response, false)

    case error do
      {:error, error} ->
        AtysApi.Responder.error(conn, error, send_response: send_response)

      {:error, error, data} ->
        AtysApi.Responder.error(conn, error, data: data, send_response: send_response)
    end
  end

  @meta_schema %{
    "type" => "object",
    "properties" => %{
      "request_id" => %{
        "type" => "number"
      }
    },
    "required" => ["request_id"]
  } |> ExJsonSchema.Schema.resolve()

  def get_values(%Conn{method: "GET"} = conn, schema) do
    with conn <- Conn.fetch_query_params(conn, length: 10_000),
         {:ok, request} <- get_json_from_query(conn),
         {:ok, values} <- extract_json(request, schema) do
      {:ok, conn, values}
    end
  end

  def get_values(conn, schema) do
    with {:ok, values} <- extract_json(conn.body_params, schema) do
      {:ok, conn, values}
    end
  end

  def respond(%Conn{} = conn, opts \\ []) do
    data = Keyword.get(opts, :data, %{})
    send_response = Keyword.get(opts, :send_response, false)

    response =
      %{
        status: :ok,
        data: data
      }
      |> Jason.encode!()

    Conn.resp(conn, 200, response)
    |> maybe_send_response(send_response)
  end

  def error(%Conn{} = conn, name, opts \\ []) do
    data = Keyword.get(opts, :data, %{})
    send_response = Keyword.get(opts, :send_response, false)
    status_code = AtysApi.Errors.get_status_code(name)

    response =
      %{
        status: :error,
        reason: name,
        data: data
      }
      |> Jason.encode!()

    Conn.resp(conn, status_code, response)
    |> maybe_send_response(send_response)
  end

  defp maybe_send_response(conn, true) do
    Plug.Conn.send_resp(conn)
  end

  defp maybe_send_response(conn, false), do: conn

  defp extract_json(json, schema) do
    with {:ok, meta, data} <- decode(json),
         :ok <- validate_to_schema(meta, @meta_schema),
         :ok <- validate_to_schema(data, schema) do
      {:ok, %{meta: meta, data: data}}
    end
  end

  defp get_json_from_query(%Conn{query_params: %{"r" => request}}), do: {:ok, request}
  defp get_json_from_query(_conn), do: {:error, Errors.reason(:invalid_param), %{missing_field: "r"}}

  defp decode(request) do
    case Jason.decode(request) do
      {:ok, %{"meta" => %{} = meta, "data" => %{} = data}} -> {:ok, meta, data}
      {:ok, _} -> {:error, Errors.reason(:cannot_decode_request)}
      {:error, _error} -> {:error, Errors.reason(:cannot_decode_request)}
    end
  end

  defp validate_to_schema(data, schema) do
    case ExJsonSchema.Validator.validate(schema, data) do
      :ok -> :ok
      {:error, errors} -> {:error, Errors.reason(:invalid_param), errors}
    end
  end
end
