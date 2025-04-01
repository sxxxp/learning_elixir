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
    # tz = [kr: 9, jp: 9, cn: 8, tw: 8, us: 0]

    locale =
      peak(language)
      |> String.split(",")
      |> peak

    if locale in @locales do
      # user_tz =
      #   tz[String.split_at(locale, -2) |> elem(1) |> String.downcase() |> String.to_atom()]
      assign(conn, :locale, locale)

      # assign(
      #   conn,
      #   :tz,
      #
      # )
    else
      assign(conn, :locale, default)
    end
  end

  # def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
  #   assign(conn, :locale, loc)
  # end

  # def call(conn, default) do
  #   assign(conn, :locale, default)
  # end
end
