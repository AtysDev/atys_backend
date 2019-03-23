use Mix.Config

config :auth,
  db_conn: [
    username: "postgres",
    password: "",
    database: "atys_dev",
    hostname: "localhost",
    port: "5432",
  ]
