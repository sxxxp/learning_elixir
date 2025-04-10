defmodule Socket do
  defmacro sock(path, module, timeout \\ 60_000, args \\ [], do: block) do
    quote do
      get unquote(path) do
        unquote(block)

        var!(conn)
        |> WebSockAdapter.upgrade(unquote(module), unquote(args), timeout: unquote(timeout))
        |> halt()
      end
    end
  end
end

defmodule Socket.Chat do
  @behaviour WebSock

  def init(options) do
    IO.puts("Socket initialized")
    {:ok, options}
  end

  def handle_in({message, [opcode: :text]}, state) do
    IO.puts("Socket received: #{message}")
    {:push, {:text, "#{message}"}, state}
  end

  def handle_in(_frame, state) do
    IO.puts("unknown frame")
    {:ok, state}
  end

  def handle_info(_, state), do: {:ok, state}

  def terminate(_, _state) do
    IO.puts("Socket terminated")
    :ok
  end
end
