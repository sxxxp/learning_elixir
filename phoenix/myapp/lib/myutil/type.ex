defmodule MyUtil.Type do
  def type(a) do
    cond do
      is_integer(a) -> :integer
      is_float(a) -> :float
      is_binary(a) -> :binary
      is_bitstring(a) -> :bitstring
      is_boolean(a) -> :boolean
      is_nil(a) -> nil
      is_list(a) -> :list
      is_tuple(a) -> :tuple
      is_map(a) -> :map
      is_atom(a) -> :atom
      is_function(a) -> :function
      true -> :unknown
    end
  end

  def peak(list) do
    case list do
      [head | _] -> head
      [] -> nil
    end
  end
end
