defmodule MyRouter.SocketRouter do
  use Router, :router
  import Socket

  sock "/:id", Socket.Chat, :infinity, id: id do
  end
end
