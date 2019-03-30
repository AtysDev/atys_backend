use Mix.Config

config :auth,
  email_salt: "qwxTYqxcp4DMU4GhP1GgnA==" |> Base.url_decode64!()

import_config "#{Mix.env()}.exs"
