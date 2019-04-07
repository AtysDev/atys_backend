use Mix.Config

config :token, machine_secrets_json: System.get_env("TOKEN_MACHINE_SECRETS")
