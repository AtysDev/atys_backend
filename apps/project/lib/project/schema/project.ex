defmodule Project.Schema.Project do
  alias Project.Repo
  alias Project.Schema.Project
  alias AtysApi.Errors
  use Ecto.Schema
  import Ecto.Changeset
  require Errors

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "projects" do
    field(:user_id, Ecto.UUID)
    field(:name, :string)
    field(:attack_probability, :float, default: 0.0)

    timestamps()
  end

  def changeset(project, params \\ %{}) do
    project
    |> cast(params, [:user_id, :name])
    |> validate_required([:user_id, :name])
  end

  def get_by_id(id) do
    with {:ok, id} <- validate_id(id),
         {:ok, project} <- query_repo(id) do
      {:ok, project}
    end
  end

  defp validate_id(id) do
    case Ecto.UUID.cast(id) do
      {:ok, id} -> {:ok, id}
      :error -> {:error, Errors.reason(:invalid_param), %{detail: "not a UUID"}}
    end
  end

  defp query_repo(id) do
    case Repo.get(Project, id) do
      nil -> {:error, Errors.reason(:item_not_found)}
      project -> {:ok, project}
    end
  end

  defimpl Jason.Encoder do
    def encode(%Project{} = project, opts) do
      Map.from_struct(project)
      |> Map.delete(:__meta__)
      |> Jason.Encode.map(opts)
    end
  end
end
