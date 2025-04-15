import Struct.Chat

defmodule Struct.Parser do
  def messageToStruct(message) do
    regex =
      Regex.run(
        ~r/%Struct\.Chat{type: :(\w+), user: "(.*?)", message: "(.*?)", time: "(.*?)"}/,
        message
      )

    case regex do
      [_, type, id, msg, time] ->
        %Struct.Chat{
          type: String.to_atom(type),
          id: id,
          message: msg,
          time: time
        }

      _ ->
        {:error, :invalid_format}
    end
  end
end
