defmodule MyUtil do
  def extract_params(params, keys) do
    Enum.map(keys, &Map.get(params, &1))
  end
end
