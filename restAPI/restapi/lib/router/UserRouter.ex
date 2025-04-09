defmodule MyRouter.UserRouter do
  @moduledoc """
  /user router

  """

  use Router, :router

  get "/" do
    send_resp(conn, 200, "hello user!")
  end

  get "/:id" do
    send_resp(conn, 200, "hello user #{id}!")
  end
end
