defmodule AuthPasswordTest do
  alias AtysBackend.TestSupport.UserGenerator
  alias Auth.User
  use ExUnit.Case
  use Plug.Test
  use Modglobal
  import Mox

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Auth.Repo)
  end
  setup :verify_on_exit!

  test "successfully resets a password" do
    {email, _} = UserGenerator.create_user()
    {conn, token} = start_valid_reset(email)
    assert 200 = conn.status

    new_password = "helloworld"
    conn = call_reset_password(%{token: token, password: new_password})
    assert 200 = conn.status

    {:ok, user} = User.get_by_email(email)
    assert :ok = User.validate_password(user, "helloworld")
  end

  test "silently ignores a password reset to an invalid email" do
    query = Jason.encode!(%{data: %{email: "notarealemail"}})
    url = "/password/reset?#{URI.encode_query(r: query)}"
    conn = conn(:get, url)
    |> put_req_header("content-type", "application/json")
    |> Auth.call(Auth.init([]))
    assert 200 = conn.status
  end

  defp start_valid_reset(email) do
    Mox.expect(Auth.EmailProviderMock, :send, fn email: _email, body:  body ->
      [_, token] = Regex.run(~r/token below:(?:\s+?)(\S+?)\n/, body)
      set_global(email, token)
      :ok
    end)

    query = Jason.encode!(%{data: %{email: email}})
    url = "/password/reset?#{URI.encode_query(r: query)}"
    conn = conn(:get, url)
    |> put_req_header("content-type", "application/json")
    |> Auth.call(Auth.init([]))

    {conn, get_global(email)}
  end

  defp call_reset_password(data) do
    conn(:post, "/password/reset", Jason.encode!(%{data: data}))
    |> put_req_header("content-type", "application/json")
    |> Auth.call(Auth.init([]))
  end
end
