use Mix.Config

# Generated with
# tokens = Jason.encode!(%{"auth" => Base.url_encode64(<<1::256>>)})
# Corresponding machine token is "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww"
config :token, machine_secrets_json: "{\"auth\":\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE=\"}"
