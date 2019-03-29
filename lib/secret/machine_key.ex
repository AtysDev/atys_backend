defmodule Secret.MachineKey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "machine_keys" do
    field(:project_id, Ecto.UUID)
    field(:key, :string)

    timestamps()
  end

  def changeset(machine_key, params \\ %{}) do
    machine_key
    |> cast(params, [:project_id, :key])
    |> validate_required([:project_id, :key])
  end
end
