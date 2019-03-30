defmodule Token do
  alias AtysApi.{Errors, Responder}
  alias Plug.Conn
  alias Token.MachineSecretStore
  require Errors
  use Plug.Builder

  @thirty_minutes 30 * 60 * 1000

  plug PlugMachineToken, issuer: MachineSecretStore
  plug AtysApi.PlugJson
  plug :route

  @create_token_schema %{
    "type" => "object",
    "properties" => %{
      "user_id" => %{
        "type" => "number"
      }
    },
    "required" => ["user_id"]
  } |> ExJsonSchema.Schema.resolve()

  @get_user_id_schema %{
    "type" => "object",
    "properties" => %{
      "token" => %{
        "type" => "string"
      }
    },
    "required" => ["token"]
  } |> ExJsonSchema.Schema.resolve()

  def route(%Conn{path_info: [], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: %{"user_id" => user_id}}} <- Responder.get_values(conn, @create_token_schema),
     {:ok, token} <- set_token(user_id) do
      Responder.respond(conn, data: %{token: token}, send_response: true)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def route(%Conn{path_info: [], method: "GET"} = conn, _opts) do
    with {:ok, conn, %{data: %{"token" => token}}} <- Responder.get_values(conn, @get_user_id_schema),
    {:ok, user_id} <- get_user_id(token) do
      Responder.respond(conn, data: %{user_id: user_id}, send_response: true)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def route(conn, _opts) do
    Conn.send_resp(conn, 404, "Unknown resource")
  end

  defp set_token(user_id) do
    token = create_token()
    case Sider.set(:token_cache, token, user_id, @thirty_minutes) do
      :ok -> {:ok, token}
      {:error, :max_capacity} -> {:error, Errors.reason(:cache_full)}
    end
  end

  defp get_user_id(token) do
    case Sider.get(:token_cache, token) do
      {:ok, user_id} -> {:ok, user_id}
      {:error, :missing_key} -> {:error, Errors.reason(:item_not_found), %{message: "token not found"}}
    end
  end

  defp create_token() do
    prefix = System.unique_integer([:positive])
    secure_token = :crypto.strong_rand_bytes(32)
    (<<prefix>> <> secure_token) |> Base.url_encode64()
  end
end
