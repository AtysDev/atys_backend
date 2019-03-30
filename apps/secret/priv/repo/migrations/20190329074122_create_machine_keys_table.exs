defmodule Secret.Repo.Migrations.CreateMachineKeysTable do
  use Ecto.Migration

  def change do
    create table("machine_keys") do
      add :project_id, :binary_id, null: false
      add :key, :text, null: false
      timestamps(type: :utc_datetime)
    end
    create(index(:machine_keys, [:project_id]))
  end
end
