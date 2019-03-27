defmodule AtysApiTest do
  use ExUnit.Case
  doctest AtysApi

  test "greets the world" do
    assert AtysApi.hello() == :world
  end
end
