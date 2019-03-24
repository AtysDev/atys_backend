defmodule Auth.MockEmailProvider do
  @behaviour Auth.EmailProvider
  def send(email: email, body: body) do
    IO.puts("Pretending to send the email to #{email}: \n\n#{body}")
    :ok
  end
end
