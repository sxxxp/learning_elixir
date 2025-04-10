defmodule MyRouter.SocketRouter do
  use Router, :router
  import Socket

  sock("/", Socket.Chat, :infinity, do: IO.puts("Socket connected!"))
end
