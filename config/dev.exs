use Mix.Config

config :auth,
  db_conn: [
    username: "postgres",
    password: "",
    database: "atys_dev",
    hostname: "localhost",
    port: "5432"
  ],
  email_provider: Auth.MockEmailProvider,
  token_url: "http://localhost:4000/"

config :cors_plug,
  origin: ["http://localhost", "http://localhost:4001"],
  max_age: 86400,
  methods: ["GET", "POST"]
