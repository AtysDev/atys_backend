use Mix.Config

config :auth, :ecto_repos, [Auth.Repo]

config :auth, Auth.Repo,
  migration_timestamps: [type: :utc_datetime],
  migration_primary_key: [name: :id, type: :binary_id]


import_config "#{Mix.env()}.exs"
