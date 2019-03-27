defmodule AtysApi.Logger do
  alias AtysApi.Error
  require Logger

  def log_response(url: url, response: {:ok, response}, opts: _opts) do
    Logger.debug("Successfully called #{url} with response #{inspect(response)}")
  end

  def log_response(url: url, response: {:error, %Error{reason: reason} = error}, opts: opts) do
    expected_failures = Keyword.get(opts, :expected_failures, [])

    if reason in expected_failures do
      Logger.debug(
        "Got an expected failure: #{reason} from #{url} with response #{inspect(error)}"
      )
    else
      Logger.error("Unexpected failure: #{reason} from #{url} with response #{inspect(error)}")
    end
  end
end
