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
    IO.puts("Hello, world!")
  end

  def gets do
    IO.gets("What's your name? ")
  end

  def pipe do
    IO.gets("?" |> String.trim() |> IO.puts())
  end

  def keywordList do
    [a: a] = [a: 1]
    IO.puts(a)
    list = [a: 2, b: 3]
    IO.puts(list[:a])
    list = [a: 1] ++ list
    IO.puts(list[:a])
  end
  def concat(a,b, sep \\ " ")
  def concat(a, b, _sep) when b=="" do
    a
  end
  def concat(a, b, sep) do
    a <> sep <> b
  end

end
