use Mix.Config

config :auth,
  email_provider: Auth.EmailProviderMock,
  token_auth_header:
    "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww"


config :auth, Auth.Repo,
  database: "atys_auth_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: :debug

config :pbkdf2_elixir, :rounds, 1
config :logger, level: :info
