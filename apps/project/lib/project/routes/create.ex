defmodule Project.Routes.Create do
  alias Plug.Conn
  alias AtysApi.{Errors, Responder}
  use Plug.Builder
  require Errors

  plug(:create)


  @create_schema %{

  } |> ExJsonSchema.Schema.resolve()

  def create(%Conn{path_info: [], method: "POST"} = conn, _opts) do
    send_resp(conn, 200, "hello world")
  end
  def create(conn, _opts), do: conn
end
