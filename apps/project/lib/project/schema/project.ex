defmodule Project.Schema.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "projects" do
    field(:user_id, Ecto.UUID)
    field(:attack_probability, :float, default: 0.0)

    timestamps()
  end

  def changeset(project, params \\ %{}) do
    project
    |> cast(params, [:user_id])
    |> validate_required([:user_id])
  end

  defimpl Jason.Encoder do
    def encode(%Project.Schema.Project{} = project, opts) do
      Map.from_struct(project)
      |> Map.delete(:__meta__)
      |> Jason.Encode.map(opts)
    end
  end
end
