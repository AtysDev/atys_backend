defmodule Token do
  alias Plug.Conn
  use Plug.Builder

  plug Plug.Parsers, parsers: [:urlencoded]
  plug :route

  def route(%Conn{path_info: [], method: "POST"} = conn, opts) do
    timeout = Keyword.get(opts, :timeout, 1_800_000)

    with {:ok, value} <- get_value(conn.body_params),
    token <- create_token(),
    :ok <- Sider.set(:token_cache, token, value, timeout)
    do
      Conn.send_resp(conn, 200, token)
    else
      {:error, :missing_v_param} -> Conn.send_resp(conn, 400, "missing value query")
      {:error, :max_capacity} -> Conn.send_resp(conn, 503, "Token cache is full")
    end
  end

  def route(%Conn{path_info: [], method: "GET"} = conn, _opts) do
    with conn <- Conn.fetch_query_params(conn, length: 10_000),
    {:ok, token} <- get_value(conn.query_params),
    {:ok, value} <- Sider.get(:token_cache, token) do
      Conn.send_resp(conn, 200, value)
    else
      {:error, :missing_v_param} -> Conn.send_resp(conn, 400, "missing value query")
      {:error, :missing_key} -> Conn.send_resp(conn, 404, "Token not valid")
    end
  end

  def route(conn, _opts) do
    Conn.send_resp(conn, 404, "Unknown resource")
  end


  defp get_value(%{"v" => value}), do: {:ok, value}
  defp get_value(_params), do: {:error, :missing_v_param}

  defp create_token() do
    prefix = System.unique_integer([:positive])
    secure_token = :crypto.strong_rand_bytes(32)
    (<<prefix>> <> secure_token) |> Base.url_encode64()
  end
end
