defmodule Socket do
  defmacro sock(path, module, timeout \\ 60, args \\ [], do: block) do
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
  def init(options) do
    {:ok, options}
  end

  def handle_in({message, [opcode: :text]}, state) do
    {:reply, :ok, {:text, "resposned: #{message}!"}, state}
  end

  def handle_in(_frame, state), do: {:ok, state}
  def handle_info(_, state), do: {:ok, state}

  def terminate(_, _state) do
    IO.puts("Socket terminated")
    :ok
  end
end
