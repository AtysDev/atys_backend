use Mix.Config

# Generated with
# Jason.encode!(%{"auth" => Base.url_encode64(<<1::256>>), "project" => Base.url_encode64(<<6::256>>)})

# Corresponding auth machine token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww"
# Corresponding project machine token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0In0.iZm1fxPMfaLCuuIUZ0XArXKwh3E9s5UkoHtih6uytYw"
# Generated with PlugMachineToken.create_machine_token(<<1::256>>, %{name: "auth"})
config :token,
  machine_secrets_json:
    "{\"auth\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE=\",\"project\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY=\"}"
