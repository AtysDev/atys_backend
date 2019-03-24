defmodule Auth.User do
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
        {:error, :email_already_exists}

      {:error, error} ->
        {:error, error}
    end
  end

  def find(email: email) do
    normalized = normalize_email(email)

    with {:ok, %Postgrex.Result{rows: [row]}} <-
           Postgrex.query(:db, "SELECT * from users where normalized_email = $1", [normalized]) do
      {:ok, row}
    else
      {:ok, _result} -> {:error, :email_not_found}
      {:error, error} -> {:error, error}
    end
  end

  defp hash_password(password), do: Pbkdf2.hash_pwd_salt(password)
end
