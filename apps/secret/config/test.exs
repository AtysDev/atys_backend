use Mix.Config

config :secret, Secret.Repo,
  database: "atys_secrets_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: :debug

config :secret,
  machine_secrets_json:
  "{\"project_api\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM=\",\"vault\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI=\"}"
