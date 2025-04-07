defmodule MyappWeb.Plugs.Locale do
  import Plug.Conn
  import MyUtil.Type
  @locales ["en-US", "ko-KR", "ja-JP", "zh-CN", "zh-TW"]

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    IO.inspect(loc)
    assign(conn, :locale, loc)
  end

  def call(conn, default) do
    language = get_req_header(conn, "accept-language")

    locale =
      peak(language)
      |> String.split(",")
      |> peak

    if locale in @locales do
      assign(conn, :locale, locale)
    else
      assign(conn, :locale, default)
    end
  end

  def getlocale(conn) do
    language = get_req_header(conn, "accept-language")

    locale =
      peak(language)
      |> String.split(",")
      |> peak

    if locale in @locales do
      locale
    else
      "en-US"
    end
  end

  # def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
  #   assign(conn, :locale, loc)
  # end

  # def call(conn, default) do
  #   assign(conn, :locale, default)
  # end
end
