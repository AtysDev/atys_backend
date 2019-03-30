defmodule Secret do
  alias AtysApi.{Errors, Responder}
  alias Plug.Conn
  alias Secret.{MachineKey, Repo}
  require Errors
  use Plug.Builder

  plug(PlugMachineToken, issuer: Secret.MachineSecretStore)
  plug(AtysApi.PlugJson)
  plug(:route)

  @create_machine_key_schema %{
                               "type" => "object",
                               "properties" => %{
                                 "project_id" => %{
                                   "type" => "string"
                                 },
                                 "key" => %{
                                   "type" => "string"
                                 }
                               },
                               "required" => ["project_id", "key"]
                             }
                             |> ExJsonSchema.Schema.resolve()
  @get_machine_key_schema %{
                            "type" => "object",
                            "properties" => %{}
                          }
                          |> ExJsonSchema.Schema.resolve()

  def route(%Conn{path_info: [], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: data}} <- Responder.get_values(conn, @create_machine_key_schema),
         {:ok, machine_id} <- insert_machine_key(data) do
      Responder.respond(conn, data: %{id: machine_id}, send_response: true)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def route(%Conn{path_info: [id], method: "GET"} = conn, _opts) do
    with {:ok, conn, _} <- Responder.get_values(conn, @get_machine_key_schema),
         {:ok, machine_key} <- get_machine_key(id) do
      Responder.respond(conn, data: machine_key, send_response: true)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def route(%Conn{path_info: [id], method: "DELETE"} = conn, _opts) do
    with {:ok, conn, _} <- Responder.get_values(conn, @get_machine_key_schema),
         :ok <- delete_machine_key(id) do
      Responder.respond(conn, send_response: true)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def route(conn, _opts) do
    Conn.send_resp(conn, 404, "Unknown resource")
  end

  defp insert_machine_key(data) do
    MachineKey.changeset(%MachineKey{}, data)
    |> Repo.insert()
    |> case do
      {:ok, %MachineKey{id: id}} ->
        {:ok, id}

      {:error, %Ecto.Changeset{errors: errors}} ->
        {:error, AtysApi.Errors.reason(:invalid_param), %{errors: errors}}
    end
  end

  defp get_machine_key(id) do
    Repo.get(MachineKey, id)
    |> case do
      nil -> {:error, AtysApi.Errors.reason(:item_not_found)}
      %Secret.MachineKey{} = machine_key -> {:ok, machine_key}
    end
  end

  defp delete_machine_key(id) do
    case Repo.delete(%MachineKey{id: id}, stale_error_field: :errors) do
      {:ok, %MachineKey{__meta__: %{state: :deleted}}} -> :ok
      {:error, %Ecto.Changeset{errors: [errors: {"is stale", [stale: true]}]}} -> :ok
      result -> {:error, AtysApi.Errors.unexpected("Deleting #{id} returned #{inspect(result)}")}
    end
  end
end
