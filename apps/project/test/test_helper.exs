Application.ensure_all_started(:project)
Ecto.Adapters.SQL.Sandbox.mode(Project.Repo, :manual)
ExUnit.start()
