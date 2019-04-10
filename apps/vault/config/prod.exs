use Mix.config()

config :vault,
  secret_auth_header: System.get_env("SECRET_AUTH_HEADER"),
  project_auth_header: System.get_env("PROJECT_AUTH_HEADER")
