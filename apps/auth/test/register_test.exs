defmodule AuthRegisterTest do
  alias AtysBackend.TestSupport.UserGenerator
  use ExUnit.Case
  use Plug.Test
  import Mox

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Auth.Repo)
  end

  setup :verify_on_exit!

  test "Successfully registers a new user" do
    email = "#{Ecto.UUID.generate()}@aty.dev"
    password = "foobar"
    expect_register_email()
    conn = call_register_user(%{email: email, password: password})
    assert 200 = conn.status
  end

  test "Send a response if the email is already registered" do
    email =
      UserGenerator.create_user()
      |> elem(0)
      |> String.upcase()

    Mox.expect(Auth.EmailProviderMock, :send, fn email: _email,
                                                 body:
                                                   "Hello! You've tried to create a new account at Atys." <>
                                                     _rest ->
      :ok
    end)

    conn = call_register_user(%{email: email, password: "foobar"})
    assert 200 = conn.status
  end

  defp expect_register_email() do
    Mox.expect(Auth.EmailProviderMock, :send, fn email: _email,
                                                 body:
                                                   "Hello! Welcome to Atys. Please confirm your email" <>
                                                     _rest ->
      :ok
    end)
  end

  defp call_register_user(data) do
    conn(:post, "/register", Jason.encode!(%{data: data}))
    |> put_req_header("content-type", "application/json")
    |> Auth.call(Auth.init([]))
  end
end
