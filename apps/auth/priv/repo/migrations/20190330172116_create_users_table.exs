defmodule Auth.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :normalized_email, :text, null: false
      add :password_hash, :text, null: false
      add :user_data, :text
      add :confirmed, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
    create unique_index(:users, [:normalized_email])
  end
end
