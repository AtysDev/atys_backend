defmodule Secret do
  alias AtysApi.{Errors, Responder}
  alias Plug.Conn
  alias Secret.{MachineKey, Repo}
  require Errors
  use Plug.Builder

  # plug PlugMachineToken, issuer: MachineSecretStore
  plug(AtysApi.PlugJson)
  plug :route

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

  def route(%Conn{path_info: [], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: data}} <- Responder.get_values(conn, @create_machine_key_schema),
      {:ok, machine_id} <- insert_machine_key(data) do
        Responder.respond(conn, data: %{id: machine_id}, send_response: true)
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
end
