defmodule Recursion do
  def print do
    for i <- 1..5 do
      IO.puts(i)
    end
    """
    for(int i=1; i<=5;i++0){
    printf("%d\n", i);
    }
    """
  end
  def print_multi(msg, n) when n>0 do
    IO.puts(msg)
    print_multi(msg, n-1)
  end
  def print_multi(_msg, 0), do: :end

  def list_sum([head | tail], acc) do
    list_sum(tail, acc + head)
  end
  def list_sum([], acc), do: IO.puts acc

  def enum do
    map = %{"a"=>1,"b"=>2}
    Enum.map(map, fn {k,v} -> {k, v*2} end)
  end
  def sum(x,acc) do
    acc = x + acc
  end
  #same each three functions
  def reduce do
    Enum.reduce([1,2,3,4,5], 0, &sum/2)
  end
  def reduce do
    Enum.reduce(1..5,0,&+/2)
  end
  def reduce do
    Enum.reduce(1..5,0,fn x,acc -> x+acc end)
  end
end

defmodule MySigil do
  def sigil_i(string,[]), do: String.to_integer(string)
  def sigil_i(string, [?n]), do: -String.to_integer(string)
  def sigil_i(_,[??]), do: {:error,"pattern not matched"}
end

defmodule FileSystem do
  defstruct [:src]
  def read do
    case File.read(:src) do
      {:ok, content} -> IO.puts content
      {:error, reason} -> File.write(:src, "Hello, world!")
    end
  end
end

defmodule PatternMatching do
  def match do
    for {:good, x} <- [good: 1 , bad: 2, good: 3], do: x
  end
end
