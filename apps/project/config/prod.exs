use Mix.Config

config :project,
  machine_secrets_json: System.get_env("TOKEN_MACHINE_SECRETS"),
  token_auth_header: System.get_env("TOKEN_AUTH_HEADER")
