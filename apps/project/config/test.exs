use Mix.Config

config :project,
  machine_secrets_json:
    "{\"project_api\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU=\",\"vault\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQ=\"}",
  token_auth_header:
    "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0In0.iZm1fxPMfaLCuuIUZ0XArXKwh3E9s5UkoHtih6uytYw"
