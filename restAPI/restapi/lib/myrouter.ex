defmodule MyRouter do
  use Plug.Router
  use RestAPI.Router
  import RestAPI.Router
  plug(:match)
  plug(:dispatch)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  pipeline :name do
    plug(Plug.Parsers,
      parsers: [:json],
      pass: ["application/json"],
      json_decoder: Jason
    )
  end

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  get "/" do
    send_resp(conn, 200, "hello!")
  end

  scope "/" do
    pipe_through(:name)

    get "/" do
      send_resp(conn, 200, "hello!")
    end
  end

  scope "/user" do
    get "/" do
      send_resp(conn, 200, "hello user!")
    end
  end

  get "/user/:id" do
    id = conn.params["id"]
    IO.inspect(id)
    send_resp(conn, 200, "hello! #{id}")
  end

  post "/login" do
    send_resp(conn, 200, "login!")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  # defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
  #   IO.inspect(_kind)
  #   send_resp(conn, conn.status, "Something went wrong")
  # end
end
