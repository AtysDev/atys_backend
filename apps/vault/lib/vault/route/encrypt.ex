defmodule Vault.Route.Encrypt do
  alias AtysApi.{Errors, Responder}
  alias AtysApi.Service.{Project, Secret}
  alias Plug.Conn
  alias Atys.Plugs.SideUnchanneler
  use Plug.Builder
  require Errors

  plug(SideUnchanneler, send_after_ms: 25)
  plug(:encrypt)
  plug(SideUnchanneler, execute: true)

  @schema %{
            "type" => "object",
            "properties" => %{
              "machine_key_id" => %{
                "type" => "string"
              },
              "machine_key" => %{
                "type" => "string"
              },
              "project_id" => %{
                "type" => "string"
              },
              "payload" => %{
                "type" => "string"
              },
              "extra" => %{
                "type" => "object",
                "properties" => %{
                  "id" => %{
                    "type" => ["number", "string"]
                  },
                  "parity_even" => %{
                    "type" => "boolean"
                  },
                  "csv_hash" => %{
                    "type" => "string"
                  }
                }
              }
            },
            "required" => ["machine_key_id", "machine_key", "payload", "project_id"]
          }
          |> ExJsonSchema.Schema.resolve()

  def encrypt(%Conn{path_info: ["encrypt"], method: "POST"} = conn, _opts) do
    auth_header = Application.get_env(:vault, :secret_auth_header)
    [request_id] = Conn.get_resp_header(conn, "x-request-id")

    with {:ok, conn,
          %{
            data: %{
              "machine_key_id" => machine_key_id,
              "project_id" => project_id,
              "machine_key" => machine_key,
              "payload" => payload,
              "extra" => extra
            }
          }} <- Responder.get_values(conn, @schema, frontend_request: true),
         {:ok, _resp} <-
           Project.can_machine_access(%{
             auth_header: auth_header,
             request_id: request_id,
             project_id: project_id
           }),
         {:ok, encrypted_machine_key} <-
           get_encrypted_machine_key(%{
             auth_header: auth_header,
             request_id: request_id,
             machine_key_id: machine_key_id,
             project_id: project_id
           }),
         {:ok, project_secret} <-
           get_project_secret(%{
             encrypted_machine_key: encrypted_machine_key,
             decryption_key: machine_key
           }),
         {:ok, serialized_payload} <-
           serialize_payload(%{project_id: project_id, payload: payload, extra: extra}),
         {:ok, ciphertext} <- encrypt_payload(project_secret, serialized_payload) do
      Responder.respond(conn, data: %{ciphertext: ciphertext})
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  defp get_encrypted_machine_key(%{
         auth_header: auth_header,
         request_id: request_id,
         machine_key_id: machine_key_id,
         project_id: project_id
       }) do
    case Secret.get_machine_key(%{
           auth_header: auth_header,
           request_id: request_id,
           id: machine_key_id
         }) do
      {:ok, %{data: %{"project_id" => ^project_id, "key" => encrypted_machine_key}}} ->
        {:ok, encrypted_machine_key}

      {:ok, _data} ->
        {:error, Errors.reason(:unauthorized)}

      {:error, %{reason: Errors.reason(:item_not_found)}} ->
        {:error, Errors.reason(:unauthorized)}
    end
  end

  defp get_project_secret(%{
         encrypted_machine_key: encrypted_machine_key,
         decryption_key: decryption_key
       }) do
    case Atys.Crypto.AES.decrypt_256(decryption_key, encrypted_machine_key) do
      {:ok, project_secret} -> {:ok, project_secret}
      {:error, reason} -> {:error, Errors.reason(:unauthorized), %{details: reason}}
    end
  end

  defp encrypt_payload(project_secret, serialized_payload) do
    case Atys.Crypto.AES.encrypt_256(project_secret, serialized_payload) do
      {:ok, ciphertext} -> {:ok, ciphertext}
      {:error, reason} -> {:error, Errors.unexpected(reason)}
    end
  end

  defp serialize_payload(%{project_id: project_id, payload: payload, extra: extra}) do
    case Jason.encode(%{project_id: project_id, payload: payload, extra: extra}) do
      {:ok, json} -> {:ok, json}
      {:error, _reason} -> {:error, Errors.reason(:cannot_encode_request)}
    end
  end
end
