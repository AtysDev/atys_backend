use Mix.Config

config :secret, machine_secrets_json: System.get_env("TOKEN_MACHINE_SECRETS")
