defmodule MyRouter.SocketRouter do
  use Router, :router
  import Socket

  sock "/", Socket.Chat, 10 do
    IO.inspect(conn)
  end
end
