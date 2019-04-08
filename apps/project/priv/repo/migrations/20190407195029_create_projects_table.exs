defmodule Project.Repo.Migrations.CreateProjectsTable do
  use Ecto.Migration

  def change do
    create table("projects") do
      add :user_id, :binary_id, null: false
      add :name, :string
      add :attack_probability, :float, null: false, default: 0.0
      timestamps(type: :utc_datetime)
    end
  end
end
