# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :project, :ecto_repos, [Project.Repo]

config :project, Project.Repo,
  migration_timestamps: [type: :utc_datetime],
  migration_primary_key: [name: :id, type: :binary_id]

import_config "#{Mix.env()}.exs"
