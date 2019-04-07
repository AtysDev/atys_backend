defmodule AtysBackend.TestSupport.UserGenerator do
  use Plug.Test
  use Modglobal

  def create_user(password \\ "foobar") do
    email = "#{Ecto.UUID.generate()}@aty.dev"

    data = %{
      email: email,
      password: password
    }

    Mox.expect(Auth.EmailProviderMock, :send, fn email: _email, body: body ->
      [_, token] = Regex.run(~r/token below:(?:\s+?)(\S+?)\n/, body)
      set_global(email, token)
      :ok
    end)

    conn(:post, "/register", Jason.encode!(%{data: data}))
    |> put_req_header("content-type", "application/json")
    |> Auth.call(Auth.init([]))

    token = get_global(email)
    {email, token}
  end

  def confirm_email(token) do
    conn(:post, "/confirm", Jason.encode!(%{data: %{token: token}}))
    |> put_req_header("content-type", "application/json")
    |> Auth.call(Auth.init([]))
  end
end
