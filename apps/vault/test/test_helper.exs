Application.stop(:project)
Application.stop(:secret)
Application.ensure_all_started(:vault)
ExUnit.start()
