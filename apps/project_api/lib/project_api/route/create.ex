defmodule ProjectApi.Route.Create do
  alias AtysApi.{Errors, Response, Responder}
  alias AtysApi.Service.{Project, Secret}
  alias Plug.Conn
  alias Atys.Plugs.SideUnchanneler
  use Plug.Builder
  require Errors

  plug(SideUnchanneler, send_after_ms: 500)
  plug(:create)
  plug(SideUnchanneler, execute: true)

  @schema %{
            "type" => "object",
            "properties" => %{
              "token" => %{
                "type" => "string"
              },
              "name" => %{
                "type" => "string"
              },
              "key" => %{
                "type" => "string"
              },
              "machine_key" => %{
                "type" => "string"
              }
            },
            "required" => ["token", "name", "key", "machine_key"]
          }
          |> ExJsonSchema.Schema.resolve()

  def create(%Conn{path_info: [], method: "POST"} = conn, _opts) do
    with {:ok, conn,
          %{data: %{"token" => token, "name" => name, "key" => key, "machine_key" => machine_key}}} <-
           Responder.get_values(conn, @schema, frontend_request: true),
          request_id <- get_request_id(conn),
         {:ok, encrypted_machine_key} <-
           get_encrypted_machine_key(key: key, machine_key: machine_key),
         {:ok, project_id} <- create_project(request_id: request_id, token: token, name: name),
         {:ok, machine_key_id} <- save_encrypted_machine_key(request_id: request_id, id: project_id, key: encrypted_machine_key) do
      Responder.respond(conn, data: %{project_id: project_id, machine_key_id: machine_key_id})
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp get_encrypted_machine_key(key: key, machine_key: machine_key) do
    case Atys.Crypto.AES.encrypt_256(machine_key, key) do
      {:ok, cipher} -> {:ok, cipher}
      {:error, reason} -> {:error, Errors.reason(:invalid_param), %{details: reason}}
    end
  end

  defp create_project(request_id: request_id, token: token, name: name) do

    auth_header = Application.get_env(:project_api, :project_auth_header)
    Project.create_project(%{
      auth_header: auth_header,
      request_id: request_id,
      token: token,
      name: name
    })
    |> case do
      {:ok, %Response{data: %{"id" => id}}} -> {:ok, id}
      {:ok, response} -> {:error, Errors.unexpected(response)}
      error -> error
    end
  end

  defp save_encrypted_machine_key(request_id: request_id, id: project_id, key: encrypted_machine_key) do
    secret_header = Application.get_env(:project_api, :secret_auth_header)
    Secret.create_machine_key(%{
      auth_header: secret_header,
      request_id: request_id,
      project_id: project_id,
      key: encrypted_machine_key
    })
    |> case do
      {:ok, %Response{data: %{"id" => id}}} -> {:ok, id}
      {:ok, response} -> {:error, Errors.unexpected(response)}
      error -> error
    end
  end

  defp get_request_id(conn) do
    [request_id] = Conn.get_resp_header(conn, "x-request-id")
    request_id
  end
end
