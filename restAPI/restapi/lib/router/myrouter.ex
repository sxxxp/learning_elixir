defmodule MyRouter do
  use Router, :router
  import MyUtil

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  get "/" do
    send_resp(conn, 200, "hello!")
  end

  forward("/user", to: MyRouter.UserRouter)
  forward("/chat", to: MyRouter.ChatRouter)
  forward("/ws", to: MyRouter.SocketRouter)

  post "/login" do
    case [name, password] = extract_params(conn.params, ["name", "password"]) do
      [nil, nil] ->
        send_resp(conn, 400, "Missing name and password")

      [nil, _] ->
        send_resp(conn, 400, "Missing name")

      [_, nil] ->
        send_resp(conn, 400, "Missing password")

      [_, _] ->
        send_resp(conn, 200, "Hello, your name #{name}, password #{password}")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  # defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
  #   IO.inspect(_kind)
  #   send_resp(conn, conn.status, "Something went wrong")
  # end
end
