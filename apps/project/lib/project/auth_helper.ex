defmodule Project.AuthHelper do
  alias Plug.Conn
  alias Project.Repo
  alias Project.Schema.Project
  alias AtysApi.{Error, Errors, Response}
  alias AtysApi.Service.Token
  use Plug.Builder
  require Errors

  def validate_token(conn, token) do
    auth_header = Application.get_env(:project, :token_auth_header)
    [request_id] = Conn.get_resp_header(conn, "x-request-id")

    Token.get_user_id(%{auth_header: auth_header, request_id: request_id, token: token})
    |> case do
      {:ok, %Response{data: %{"user_id" => user_id}}} -> {:ok, user_id}
      {:ok, response} -> {:error, Errors.unexpected(response)}
      {:error, %Error{reason: Errors.reason(:item_not_found)}} -> {:error, Errors.reason(:unauthorized)}
      {:error, response} -> {:error, Errors.unexpected(response)}
    end
  end

  def validate_authorized(%{id: project_id, user_id: user_id}) do
    case Project.get_by_id(project_id) do
      {:ok, %Project{user_id: ^user_id} = project} -> validate_not_locked_out(project)
      {:ok, _project} -> {:error, Errors.reason(:unauthorized)}
      error -> error
    end
  end

  def validate_not_locked_out(%Project{attack_probability: probability}) do
    case probability < 0.8 do
      true -> :ok
      false -> {:error, Errors.reason(:locked_out)}
    end
  end
end
