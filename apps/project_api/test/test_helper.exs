Application.stop(:project)
Application.ensure_all_started(:project_api)
ExUnit.start()
