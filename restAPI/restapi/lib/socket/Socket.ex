defmodule Socket.Chat do
  @behaviour WebSock
  import ChatLogger
  import Struct.Parser, only: [messageToStruct: 1]
  import Struct.Chat

  def init(options) do
    :pg.join({:chat_room, options[:id]}, self())
    IO.puts("Socket initialized")
    {:ok, options}
  end

  def handle_in({message, [opcode: :text]}, state) do
    message = messageToStruct(message)
    do_handle(message, state)
  end

  def do_handle(%Struct.Chat{type: :join} = msg, state) do
    data = read(state[:id]) <> "\n"
    text = "[입장] #{msg.id} - #{msg.time}"
    log(state[:id], text)
    broadcast(:join, text, state)
    {:push, {:text, data <> text}, state}
  end

  def do_handle(%Struct.Chat{type: :send} = msg, state) do
    text = "#{msg.id}: #{msg.message} - #{msg.time}"
    log(state[:id], text)
    broadcast(:send, text, state)
    {:push, {:text, text}, state}
  end

  def do_handle(%Struct.Chat{type: :exit} = msg, state) do
    text = "[퇴장] #{msg.id} - #{msg.time}"
    log(state[:id], text)
    broadcast(:exit, text, state)
    {:push, {:text, text}, state}
  end

  def do_handle(_, state) do
    {:ok, state}
  end

  def handle_info(send, _state) do
    send
  end

  def broadcast(:join, msg, state) do
    for pid <- :pg.get_members({:chat_room, state[:id]}), pid != self() do
      send(pid, {:push, {:text, msg}, state})
    end
  end

  def broadcast(:send, msg, state) do
    for pid <- :pg.get_members({:chat_room, state[:id]}), pid != self() do
      send(pid, {:push, {:text, msg}, state})
    end
  end

  def broadcast(:exit, msg, state) do
    for pid <- :pg.get_members({:chat_room, state[:id]}), pid != self() do
      send(pid, {:push, {:text, msg}, state})
    end
  end

  def terminate(_, state) do
    IO.puts("Socket terminated")
    :pg.leave({:chat_room, state[:id]}, self())
    :ok
  end
end
