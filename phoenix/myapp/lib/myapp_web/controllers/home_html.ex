defmodule MyappWeb.HomeHTML do
  use MyappWeb, :html
  # def index(assigns) do
  #   ~H"""
  #   <h1>Welcome to Phoenix!</h1>
  #   """
  # end
  embed_templates("home_html/*")
end
