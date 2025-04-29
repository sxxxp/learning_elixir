defmodule Struct.Chat do
  @enforce_keys [:type, :user, :message, :time]
  defstruct [
    :type,
    time: %MyTime{year: 0000, month: 00, day: 00, hour: 00, minute: 00},
    user: "[system]",
    message: "error"
  ]

  def migrate(%{type: type, user: user, message: message, time: time}) do
    %Struct.Chat{
      type: type,
      user: user,
      message: message,
      time: MyTime.converter(time)
    }
  end

  def migrate(%Struct.Chat{} = msg) do
    Jason.encode!(%{
      type: msg.type,
      user: msg.user,
      message: msg.message,
      time: MyTime.get_to_string(msg.time)
    })
  end

  def migrate(_), do: {:error, :invalid_format}

  def to_string(%Struct.Chat{} = msg) do
    "{\"type\": \"#{msg.type}\",\"user\": \"#{msg.user}\", \"message\": \"#{msg.message}\", \"time\": \"#{MyTime.get_to_string(msg.time)}\"}"
  end
end
