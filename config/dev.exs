use Mix.Config

config :secret, Secret.Repo,
  database: "atys_secrets_dev",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432
