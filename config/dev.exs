use Mix.Config

config :secret, Secret.Repo,
  database: "atys_secrets_dev",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432

# Generated with
# tokens = Jason.encode!(%{"auth" => Base.url_encode64(<<2::256>>)})

# Corresponding vault token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2YXVsdCJ9.UAeEJ70l5YfyZ_4z_Qi4oD0U1En2ZdRZiKlEWsSUlRs"
# This was generated with  PlugMachineToken.create_machine_token(<<2::256>>, %{name: "vault"})
config :secret, machine_secrets_json: "{\"vault\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI=\"}"
