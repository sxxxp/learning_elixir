defmodule RestapiTest do
  use ExUnit.Case
  doctest Restapi
  import Plug.Test
  import Plug.Conn

  @opts MyRouter.init([])

  test "test Server" do
    conn = conn(:get, "/user")

    # Invoke the plug
    conn = MyRouter.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "hello user!"
  end
end
