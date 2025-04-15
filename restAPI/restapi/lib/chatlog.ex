defmodule ChatLogger do
  def log(room_id, message) do
    File.write("chat_logs/#{room_id}.log", "#{message}\n", [:append])
  end

  def read(room_id) do
    file_path = "chat_logs/#{room_id}.log"

    case File.read(file_path) do
      {:ok, content} ->
        String.split(content, "\n", trim: true) |> Enum.join("\n")

      {:error, _reason} ->
        "No messages found"
    end
  end
end
