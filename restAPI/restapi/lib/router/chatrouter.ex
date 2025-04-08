defmodule MyRouter.ChatRouter do
  use Router, :router

  get "/:message" do
    send_resp(conn, 200, "#{message}")
  end

  match _ do
    send_resp(conn, 404, "You should send a message")
  end
end
