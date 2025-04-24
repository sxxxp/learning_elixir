defmodule ChatLogger do
  def log(room_id, %Struct.Chat{} = msg) do
    File.write("chat_logs/#{room_id}.log", "#{Struct.Chat.to_string(msg)}\n", [:append])
  end

  def log(room_id, message) do
    File.write("chat_logs/#{room_id}.log", "#{message}\n", [:append])
  end

  def read(room_id) do
    file_path = "chat_logs/#{room_id}.log"

    case File.read(file_path) do
      {:ok, content} ->
        String.split(content, "\n", trim: true)

      {:error, _reason} ->
        ""
    end
  end

  def readLast(room_id) do
    file_path = "chat_logs/#{room_id}.log"

    case File.read(file_path) do
      {:ok, content} ->
        lines = String.split(content, "\n", trim: true)
        last_line = List.last(lines)
        last_line

      {:error, _reason} ->
        ""
    end
  end

  def to_jason(%Struct.Chat{} = msg) do
    Jason.encode!(msg)
  end
end
