defmodule Struct.Chat do
  @enforce_keys [:type, :id, :message, :time]
  defstruct [:id, type: :send, message: "hi", time: DateTime.utc_now() |> DateTime.to_string()]
end
