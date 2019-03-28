defmodule AtysApi.Responder do
  alias Plug.Conn
  require AtysApi.Errors
  alias AtysApi.Errors

  @spec handle_error(Plug.Conn.t(), {:error, %AtysApi.Error{} | atom()} | {:error, atom(), map()}, keyword()) ::
          Plug.Conn.t()
  def handle_error(conn, error, opts \\ []) do
    send_response = Keyword.get(opts, :send_response, false)

    case error do
      {:error, %AtysApi.Error{reason: reason}} ->
        AtysApi.Responder.error(conn, reason, send_response: send_response)

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
                     "type" => "string"
                   }
                 },
                 "required" => ["request_id"]
               }
               |> ExJsonSchema.Schema.resolve()

  def get_values(conn, schema), do: get_values(conn, schema, [])
  def get_values(%Conn{method: "GET"} = conn, %ExJsonSchema.Schema.Root{} = schema, opts) do
    with conn <- Conn.fetch_query_params(conn, length: 10_000),
         {:ok, request} <- get_json_from_query(conn),
         {:ok, decoded} <- decode(request),
         {:ok, values} <- verify_request(decoded, schema, opts) do
      {:ok, conn, values}
    end
  end

  def get_values(conn,  %ExJsonSchema.Schema.Root{} = schema, opts) do
    with {:ok, values} <- verify_request(conn.body_params, schema, opts) do
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

  defp verify_request(decoded, schema, opts) do
    case Keyword.get(opts, :frontend_request, false) do
      true -> verify_frontend_request(decoded, schema)
      false -> verify_backend_request(decoded, schema)
    end
  end

  def verify_frontend_request(decoded, schema) do
    with {:ok, data} <- get_data(decoded),
         :ok <- validate_to_schema(data, schema) do
      {:ok, %{data: data}}
    end
  end

  def verify_backend_request(decoded, schema) do
    with {:ok, meta} <- get_meta(decoded),
         {:ok, data} <- get_data(decoded),
         :ok <- validate_to_schema(meta, @meta_schema),
         :ok <- validate_to_schema(data, schema) do
      {:ok, %{meta: meta, data: data}}
    end
  end

  defp get_json_from_query(%Conn{query_params: %{"r" => request}}), do: {:ok, request}

  defp get_json_from_query(_conn),
    do: {:error, Errors.reason(:invalid_param), %{missing_field: "r"}}


  defp get_meta(%{"meta" => %{} = meta}), do: {:ok, meta}
  defp get_meta(_), do: {:error, Errors.reason(:cannot_decode_request)}

  defp get_data(%{"data" => %{} = data}), do: {:ok, data}
  defp get_data(_), do: {:error, Errors.reason(:cannot_decode_request)}

  defp decode(request) do
    case Jason.decode(request) do
      {:ok, response} -> {:ok, response}
      {:error, _error} -> {:error, Errors.reason(:cannot_decode_request)}
    end
  end

  @spec validate_to_schema(map(), ExJsonSchema.Schema.Root.t) :: :ok | {:errors, atom(), map()}
  defp validate_to_schema(%{} = data, %ExJsonSchema.Schema.Root{} = schema) do
    case ExJsonSchema.Validator.validate(schema, data) do
      :ok -> :ok
      {:error, errors} -> {:error, Errors.reason(:invalid_param), %{keys: errors}}
    end
  end
end
