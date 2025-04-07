defmodule RestapiTest do
  use ExUnit.Case
  doctest Restapi

  test "greets the world" do
    assert Restapi.hello() == :world
  end
end
