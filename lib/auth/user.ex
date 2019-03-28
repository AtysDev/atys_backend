defmodule Auth.User do
  alias AtysApi.Errors
  require Errors

  defstruct id: nil, password_hash: nil, user_data: %{}, confirmed?: false

  def normalize_email(email) do
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

  def create(email: email, password: password) do
    user_data = %{email: email} |> Jason.encode!()

    Postgrex.query(
      :db,
      "INSERT into users (normalized_email, password_hash, user_data) VALUES($1, $2, $3) RETURNING id",
      [
        normalize_email(email),
        hash_password(password),
        user_data
      ]
    )
    |> case do
      {:ok, %Postgrex.Result{columns: ["id"], rows: [[user_id]]}} ->
        {:ok, user_id}

      {:error,
       %Postgrex.Error{
         postgres: %{code: :unique_violation, constraint: "users_normalized_email_key"}
       }} ->
        {:error, Errors.reason(:item_already_exists)}

      {:error, error} ->
        {:error, Errors.reason(:unexpected)}
    end
  end

  def confirm_email(id) do
    Postgrex.query(:db, "UPDATE users set confirmed = true WHERE id = $1", [id])
    |> parse_update_result()
  end

  def update_password(id, password) do
    hashed = hash_password(password)

    Postgrex.query(:db, "UPDATE users set password_hash = $2 WHERE id = $1", [id, hashed])
    |> parse_update_result()
  end

  def validate_password(%Auth.User{password_hash: hash}, password) do
    case Pbkdf2.verify_pass(password, hash) do
      true -> :ok
      false -> {:error, Errors.reason(:unauthorized)}
    end
  end

  def find(email: email) do
    normalized = normalize_email(email)

    with {:ok, %Postgrex.Result{rows: [row]}} <-
           Postgrex.query(:db, "SELECT * from users where normalized_email = $1", [normalized]) do
      [id, _email_normalized, password_hash, user_data, confirmed] = row

      user = %Auth.User{
        id: id,
        password_hash: password_hash,
        user_data: Jason.decode!(user_data),
        confirmed?: confirmed
      }

      {:ok, user}
    else
      {:ok, _result} -> {:error, Errors.reason(:item_not_found)}
      {:error, _error} -> {:error, Errors.reason(:cannot_contact_server)}
    end
  end

  defp parse_update_result(query_result) do
    case query_result do
      {:ok, %Postgrex.Result{num_rows: 1}} -> :ok
      _ -> {:error, Errors.reason(:unexpected)}
    end
  end

  defp hash_password(password), do: Pbkdf2.hash_pwd_salt(password)
end
