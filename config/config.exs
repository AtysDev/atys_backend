# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :secret,
  :ecto_repos, [Secret.Repo]

config :secret, Secret.Repo,
  migration_timestamps: [type: :utc_datetime],
  migration_primary_key: [name: :id, type: :binary_id]

import_config "#{Mix.env()}.exs"
