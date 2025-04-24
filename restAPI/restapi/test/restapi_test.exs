defmodule RestapiTest do
  use ExUnit.Case
  import Plug.Test
  import Plug.Conn

  @opts MyRouter.init([])

  test "test Server" do
    Jason.encode!(%{
      type: :message,
      id: "123",
      message: "Hello, world!",
      time: "2025-04-21T12:00:00Z"
    })
  end
end
