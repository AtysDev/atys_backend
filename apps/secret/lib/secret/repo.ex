defmodule Secret.Repo do
  use Ecto.Repo,
    otp_app: :secret,
    adapter: Ecto.Adapters.Postgres
end
