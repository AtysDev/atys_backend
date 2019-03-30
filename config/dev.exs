use Mix.Config

config :secret, Secret.Repo,
  database: "atys_secrets_dev",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432

# Generated with
# Jason.encode!(%{"vault" => Base.url_encode64(<<2::256>>), "project" => Base.url_encode64(<<3::256>>)})

# Corresponding vault token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2YXVsdCJ9.UAeEJ70l5YfyZ_4z_Qi4oD0U1En2ZdRZiKlEWsSUlRs"
# Corresponding project token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0In0.cCv-qhkgjUzGlDk1QDckdq1WY5eNdm8ldkwgMswtjMg"
# This was generated with  PlugMachineToken.create_machine_token(<<2::256>>, %{name: "vault"})
config :secret,
  machine_secrets_json: "{\"project\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM=\",\"vault\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI=\"}"
