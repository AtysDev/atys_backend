defmodule Auth.User do
  alias AtysApi.Errors
  alias Auth.User
  alias Auth.Repo
  require Errors
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "users" do
    field(:email, :string, virtual: true)
    field(:normalized_email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:user_data, :string)
    field(:confirmed, :boolean)
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :password])
    |> normalize_email()
    |> set_user_data()
    |> hash_password()
    |> unique_constraint(:normalized_email)
    |> validate_required([:normalized_email, :password_hash])
  end

  def set_password(user, password) do
    user
    |> change(%{password: password})
    |> hash_password()
    |> validate_required([:password_hash])
  end

  def get_email_address(%User{user_data: user_data}) do
    Jason.decode!(user_data)["email"]
  end

  def get_by_id(id) do
    case Repo.get(User, id) do
      nil -> {:error, Errors.reason(:item_not_found)}
      user -> {:ok, user}
    end
  end

  def get_by_email(email) do
    case Repo.get_by(User, normalized_email: get_normalized_email(email)) do
      nil -> {:error, Errors.reason(:item_not_found)}
      user -> {:ok, user}
    end
  end

  def validate_password(%User{password_hash: password_hash}, password) do
    case Pbkdf2.verify_pass(password, password_hash) do
      true -> :ok
      false -> {:error, Errors.reason(:unauthorized)}
    end
  end

  defp normalize_email(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    put_change(changeset, :normalized_email, get_normalized_email(email))
  end

  defp normalize_email(changeset), do: changeset

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
    |> delete_change(:password)
  end

  defp hash_password(changeset) do
    delete_change(changeset, :password)
  end

  defp set_user_data(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    case Jason.encode(%{email: email}) do
      {:ok, user_data} -> put_change(changeset, :user_data, user_data)
      _error -> add_error(changeset, :user_data, "Cannot encode user_data")
    end
  end

  defp set_user_data(changeset), do: changeset

  defp get_normalized_email(email) do
    String.downcase(email)
    |> String.split("@")
    |> case do
      [user, domain] ->
        String.replace(user, ~r/[-+=].*/, "")
        |> String.replace(".", "")
        |> Kernel.<>("@" <> domain)

      [email] ->
        email
    end
  end
end
