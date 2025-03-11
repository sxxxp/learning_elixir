
defmodule Learning do
  @moduledoc """
  Documentation for `Learning`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Learning.hello()
      :world

  """
  def hello do
    :world
  end
end

defmodule IOTest do
  def test do
    IO.puts "Hello, world!"
  end
  def gets do
    IO.gets "What's your name? "
  end
  def pipe do
    IO.gets "?" |> String.trim |> IO.puts
  end
end
