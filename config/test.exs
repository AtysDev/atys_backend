use Mix.Config

config :auth,
  email_provider: Auth.MockEmailProvider

config :pbkdf2_elixir, :rounds, 1
