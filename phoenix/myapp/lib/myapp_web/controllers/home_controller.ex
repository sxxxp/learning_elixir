defmodule MyappWeb.HomeController do
  use MyappWeb, :controller

  def index(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, layout: false)
  end
end
