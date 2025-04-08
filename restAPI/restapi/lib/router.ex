defmodule Router do
  def router do
    quote do
      use Plug.Router
      import Plug.Router
      plug(Plug.Logger)

      plug(Plug.Parsers,
        parsers: [:json, :urlencoded, :multipart],
        pass: ["*/*"],
        # pass: ["application/json", "mutipart/form-data", "application/x-www-form-urlencoded"],
        json_decoder: Jason
      )

      plug(:match)
      plug(:dispatch)
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
