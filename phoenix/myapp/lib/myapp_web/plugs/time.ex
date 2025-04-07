defmodule MyappWeb.Plugs.Time do
  import Plug.Conn

  def init(default), do: default

  # def call(conn, default) do

  #   assign(conn, :time, Time.utc_now())
  # end
  def call(conn, _default) do
    time = Time.utc_now()
    IO.inspect(time)
    assign(conn, :time, time)
  end
end
