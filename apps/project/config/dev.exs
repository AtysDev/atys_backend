use Mix.Config

config :project, Project.Repo,
  database: "atys_project_dev",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432

# Generated with
# Jason.encode!(%{"vault" => Base.url_encode64(<<4::256>>), "project_api" => Base.url_encode64(<<5::256>>)})

# Corresponding vault machine token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2YXVsdCJ9.jAMK0pefZDhcVMSYu-DwcgRX4rLn5PA-r0m9CB2_zXc"
# Corresponding project_api machine token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0X2FwaSJ9.v8suXLqJ5Vm6eXddObCZc2izMrF_hxbSTQiHObKZpaM"
# Generated with PlugMachineToken.create_machine_token(<<4::256>>, %{name: "vault"})
config :project,
  machine_secrets_json:
    "{\"project_api\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU=\",\"vault\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQ=\"}",
  token_auth_header:
    "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0In0.iZm1fxPMfaLCuuIUZ0XArXKwh3E9s5UkoHtih6uytYw"
