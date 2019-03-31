use Mix.Config

config :auth, Auth.Repo,
  database: "atys_auth_dev",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432

config :auth,
  email_provider: Auth.DevEmailProvider,
  token_auth_header:
    "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww"

config :cors_plug,
  origin: ["http://localhost", "http://localhost:4001"],
  max_age: 86400,
  methods: ["GET", "POST"]
