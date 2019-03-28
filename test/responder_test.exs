defmodule ResponderTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "Working pipeline" do
    defmodule WorkingResponder do
      require AtysApi.Responder
      use Plug.Builder

      plug(AtysApi.PlugJson)
      plug(:route)

      def route(conn, _opts) do
        schema = %{
          "type" => "object",
          "properties" => %{
            "user_id" => %{
              "type" => "number"
            }
          },
          "required" => ["user_id"]
        } |> ExJsonSchema.Schema.resolve()

        with {:ok, conn, values} <- AtysApi.Responder.get_values(conn, schema) do
          %{data: %{"user_id" => user_id}} = values
          AtysApi.Responder.respond(conn, data: %{resp: user_id + 1}, send_response: true)
        else
          error -> AtysApi.Responder.handle_error(conn, error)
        end
      end
    end

    request_data =
      Jason.encode!(%{
        meta: %{request_id: 1},
        data: %{user_id: 22}
      })

    query = URI.encode_query(r: request_data)
    conn = conn(:get, "/?#{query}") |> WorkingResponder.call([])
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "{\"data\":{\"resp\":23},\"status\":\"ok\"}"
  end
end
