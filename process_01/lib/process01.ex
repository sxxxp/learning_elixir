defmodule Process.Sending do
  @moduledoc """
  Module for demonstrating sending messages between processes.
  """

  @doc """
  Sends a message to the current process.
  """
  def send_message do
    send(self(), {:data, "some data", self()})
  end

  def send_message(:new) do
    IO.puts("sender: #{inspect(self())}")
    pid = spawn(fn -> recv_message() end)
    send(pid, {:data, "some data", self()})

    receive do
      {:ok, reply_pid, _} when reply_pid == pid ->
        IO.puts(Process.alive?(reply_pid))
        "success"

      _ ->
        "failure"
    end
  end

  def send_message(:new, data) do
    IO.puts("sender: #{inspect(self())}")
    pid = spawn(fn -> recv_message() end)
    send(pid, {:data, data, self()})

    receive do
      {:ok, reply_pid, _} when reply_pid == pid ->
        "success"

      _ ->
        "failure"
    end
  end

  def send_message(:new, data, receiver, timeout \\ 500) do
    send(receiver, {:data, data, self()})

    receive do
      {:ok, reply_pid, _} when reply_pid == receiver ->
        "success"

      _ ->
        "failure"
    after
      timeout ->
        "timeout"
    end
  end

  def broadcast_message(data) do
    for receiver <- :pg.get_members({:message, 0}), receiver != self() do
      send_message(:new, data, receiver, 1000)
    end
  end

  def join_group do
    :pg.join({:message, 0}, self())
  end

  @doc """
  Receives a message and prints its contents.
  """
  def recv_message do
    receive do
      {:data, data, sender} ->
        IO.puts("Received data: #{data} from #{inspect(sender)}")
        send(sender, {:ok, self(), "received your data"})

      _ ->
        IO.puts("Received unknown message")
    end
  end
end
