use Mix.Config

config :project, Project.Repo,
  database: "atys_project_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: :debug

config :project,
  machine_secrets_json:
  "{\"project_api\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU=\",\"secret\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAc=\",\"vault\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQ=\"}",
  token_auth_header:
    "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0In0.iZm1fxPMfaLCuuIUZ0XArXKwh3E9s5UkoHtih6uytYw"

config :logger, level: :info
