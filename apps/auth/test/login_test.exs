defmodule AuthLoginTest do
  alias Auth.User
  alias AtysBackend.TestSupport.UserGenerator
  use ExUnit.Case
  use Plug.Test
  use Modglobal
  import Mox

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Auth.Repo)
  end
  setup :verify_on_exit!

  test "Successfully logs in" do
    {email, token} = UserGenerator.create_user()
    UserGenerator.confirm_email(token)

    conn = call_login(%{email: email, password: "foobar"})
    assert 200 = conn.status
  end

  defp call_login(data) do
    Task.async(fn ->
      conn(:post, "/login", Jason.encode!(%{data: data}))
      |> put_req_header("content-type", "application/json")
      |> Auth.call(Auth.init([]))
    end)
    |> Task.await()
  end
end
