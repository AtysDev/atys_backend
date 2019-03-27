defmodule AtysApi.Logger do
  alias AtysApi.Error
  require Logger

  def log_response(url, {:ok, response}) do
    Logger.debug("Successfully called #{url} with response #{inspect(response)}")
  end

  def log_response(url, {:error, %Error{reason: reason, expected: true} = error}) do
    Logger.debug("Got an expected failure: #{reason} from #{url} with response #{inspect(error)}")
  end

  def log_response(url, {:error, %Error{reason: reason} = error}) do
    Logger.error("Unexpected failure: #{reason} from #{url} with response #{inspect(error)}")
  end
end
