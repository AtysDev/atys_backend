Application.ensure_all_started(:auth)
Ecto.Adapters.SQL.Sandbox.mode(Auth.Repo, :manual)
Mox.defmock(Auth.EmailProviderMock, for: Auth.EmailProvider)
ExUnit.start()
