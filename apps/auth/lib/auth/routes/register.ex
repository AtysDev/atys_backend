defmodule Auth.Routes.Register do
  alias Plug.Conn
  alias Auth.User
  alias Auth.Email
  alias Auth.Repo
  alias Atys.Plugs.SideUnchanneler
  alias AtysApi.{Errors, Responder}
  use Plug.Builder
  require Errors

  plug(SideUnchanneler, send_after_ms: 500)
  plug(:create)
  plug(SideUnchanneler, execute: true)

  @register_schema %{
                     "type" => "object",
                     "properties" => %{
                       "email" => %{
                         "type" => "string"
                       },
                       "password" => %{
                         "type" => "string"
                       }
                     },
                     "required" => ["email", "password"]
                   }
                   |> ExJsonSchema.Schema.resolve()

  def create(%Conn{path_info: ["register"], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: data}} <-
           Responder.get_values(conn, @register_schema, frontend_request: true),
         :ok <- create_and_send_email(data) do
      Responder.respond(conn)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp create_and_send_email(data) do
    case insert_user(data) do
      {:ok, user} -> Email.confirm_email_address(user)
      {:error, Errors.reason(:item_already_exists)} -> Email.trying_to_reregister(data["email"])
      error -> error
    end
  end

  defp insert_user(data) do
    User.changeset(%User{}, data)
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, user}

      {:error, changeset} ->
        if email_exists?(changeset) do
          {:error, AtysApi.Errors.reason(:item_already_exists)}
        else
          {:error, AtysApi.Errors.reason(:invalid_param), %{errors: sanitize_errors(changeset)}}
        end
    end
  end

  @email_exists_error {"has already been taken",
                       [constraint: :unique, constraint_name: "users_normalized_email_index"]}

  defp sanitize_errors(%Ecto.Changeset{errors: errors}) do
    Keyword.delete(errors, :normalized_email, @email_exists_error)
  end

  defp email_exists?(%Ecto.Changeset{errors: [normalized_email: @email_exists_error]}), do: true
  defp email_exists?(_), do: false
end
