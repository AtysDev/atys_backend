use Mix.Config

config :secret, Secret.Repo,
  database: "atys_secrets_dev",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432

# Generated with
# Jason.encode!(%{"vault" => Base.url_encode64(<<2::256>>), "project_api" => Base.url_encode64(<<3::256>>)})

# Corresponding vault token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2YXVsdCJ9.UAeEJ70l5YfyZ_4z_Qi4oD0U1En2ZdRZiKlEWsSUlRs"
# Corresponding project_api token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0X2FwaSJ9.8eZo6skLWPhTs7xs1dBptJCOUBey1h1_kSy5dJ33rCE"
# This was generated with  PlugMachineToken.create_machine_token(<<2::256>>, %{name: "vault"})
config :secret,
  machine_secrets_json:
  "{\"project_api\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM=\",\"vault\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI=\"}"
