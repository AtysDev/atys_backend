use Mix.Config

config :project_api,
  project_auth_header: System.get_env("PROJECT_AUTH_HEADER"),
  secret_auth_header: System.get_env("SECRET_AUTH_HEADER")
