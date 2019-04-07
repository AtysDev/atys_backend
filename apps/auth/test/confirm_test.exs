defmodule AuthConfirmTest do
  alias Auth.User
  alias AtysBackend.TestSupport.UserGenerator
  use ExUnit.Case
  use Plug.Test
  import Mox

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Auth.Repo)
  end

  setup :verify_on_exit!

  test "Successfully confirms" do
    {email, token} = UserGenerator.create_user()

    conn = call_confirm_user(%{token: token})
    assert 200 = conn.status

    assert {:ok, %User{confirmed: true}} = User.get_by_email(email)
  end

  test "Returns unauthorized if the token is not valid" do
    conn = call_confirm_user(%{token: "wrong_token"})
    assert 403 = conn.status
  end

  defp call_confirm_user(data) do
    conn(:post, "/confirm", Jason.encode!(%{data: data}))
    |> put_req_header("content-type", "application/json")
    |> Auth.call(Auth.init([]))
  end
end
