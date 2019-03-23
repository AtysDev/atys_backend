use Mix.Config

config :auth,
  db_conn: [
    username: System.get_env("DB_USERNAME")
    password: System.get_env("DB_PASSWORD"),
    database: System.get_env("DB_NAME"),
    hostname: System.get_env("DB_HOST"),
    port: System.get_env("DB_PORT"),
  ]
