defmodule Process01Test do
  use ExUnit.Case
  doctest Process01

  test "greets the world" do
    assert Process01.hello() == :world
  end
end
