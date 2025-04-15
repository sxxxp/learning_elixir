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
