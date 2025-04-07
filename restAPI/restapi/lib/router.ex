defmodule RestAPI.Router do
  alias RestAPI.Router.{Scope, Route}

  defmacro __using__(_) do
    quote do
      unquote(prelude())
      unquote(defs())
      unquote(match_dispatch())
    end
  end

  def plug_init_mode do
    Application.get_env(:restapi, :plug_init_mode, :compile)
  end

  defmacro pipeline(plug, do: block) do
    with true <- is_atom(plug),
         imports = __CALLER__.macros ++ __CALLER__.functions,
         {mod, _} <- Enum.find(imports, fn {_, imports} -> {plug, 2} in imports end) do
      raise ArgumentError,
            "cannot define pipeline named #{inspect(plug)} " <>
              "because there is an import from #{inspect(mod)} with the same name"
    end

    block =
      quote do
        plug = unquote(plug)
        @restapi_pipeline []
        unquote(block)
      end

    compiler =
      quote unquote: false do
        Scope.pipeline(__MODULE__, plug)

        {conn, body} =
          Plug.Builder.compile(__ENV__, @restapi_pipeline, init_mode: plug_init_mode())

        def unquote(plug)(unquote(conn), _) do
          try do
            unquote(body)
          rescue
            e in Plug.Conn.WrapperError ->
              Plug.Conn.WrapperError.reraise(e)
          catch
            :error, reason ->
              Plug.Conn.WrapperError.reraise(unquote(conn), :error, reason, __STACKTRACE__)
          end
        end

        @restapi_pipeline nil
      end

    quote do
      try do
        unquote(block)
        unquote(compiler)
      after
        :ok
      end
    end
  end

  defmacro pipe_through(pipes) do
    pipes =
      if plug_init_mode() == :runtime and Macro.quoted_literal?(pipes) do
        Macro.prewalk(pipes, &expand_alias(&1, __CALLER__))
      else
        pipes
      end

    quote do
      if pipeline = @restapi_pipeline do
        raise "cannot pipe_through inside a pipeline"
      else
        Scope.pipe_through(__MODULE__, unquote(pipes))
      end
    end
  end

  # @http_methods [:get, :post, :put, :patch, :delete, :options, :connect, :trace, :head]

  defmacro resources(path, controller, opts, do: nested_context) do
    add_resources(path, controller, opts, do: nested_context)
  end

  @doc """
  See `resources/4`.
  """
  defmacro resources(path, controller, do: nested_context) do
    add_resources(path, controller, [], do: nested_context)
  end

  defmacro resources(path, controller, opts) do
    add_resources(path, controller, opts, do: nil)
  end

  @doc """
  See `resources/4`.
  """
  defmacro resources(path, controller) do
    add_resources(path, controller, [], do: nil)
  end

  defp add_resources(path, controller, options, do: context) do
    scope =
      if context do
        quote do
          scope(resource.member, do: unquote(context))
        end
      end

    quote do
      resource = Resource.build(unquote(path), unquote(controller), unquote(options))
      var!(add_resources, RestAPI.Router).(resource)
      unquote(scope)
    end
  end

  defp defs() do
    quote unquote: false do
      var!(add_resources, RestAPI.Router) = fn resource ->
        path = resource.path
        mod = resource.controller
        opts = resource.route

        # if resource.singleton do
        #   Enum.each(resource.actions, fn
        #     :show ->
        #       get(path, mod, :show, opts)

        #     :new ->
        #       get(path <> "/new", mod, :new, opts)

        #     :edit ->
        #       get(path <> "/edit", mod, :edit, opts)

        #     :create ->
        #       post(path, mod, :create, opts)

        #     :delete ->
        #       delete(path, mod, :delete, opts)

        #     :update ->
        #       patch(path, mod, :update, opts)
        #       put(path, mod, :update, Keyword.put(opts, :as, nil))
        #   end)
        # else
        #   param = resource.param

        #   Enum.each(resource.actions, fn
        #     :index ->
        #       get(path, mod, :index, opts)

        #     :show ->
        #       get(path <> "/:" <> param, mod, :show, opts)

        #     :new ->
        #       get(path <> "/new", mod, :new, opts)

        #     :edit ->
        #       get(path <> "/:" <> param <> "/edit", mod, :edit, opts)

        #     :create ->
        #       post(path, mod, :create, opts)

        #     :delete ->
        #       delete(path <> "/:" <> param, mod, :delete, opts)

        #     :update ->
        #       patch(path <> "/:" <> param, mod, :update, opts)
        #       put(path <> "/:" <> param, mod, :update, Keyword.put(opts, :as, nil))
        #   end)
        # end
      end
    end
  end

  defp build_verify(path, routes_per_path) do
    routes = Map.get(routes_per_path, path)

    forward_plug =
      Enum.find_value(routes, fn
        %{kind: :forward, plug: plug} -> plug
        _ -> nil
      end)

    warn_on_verify? = Enum.all?(routes, & &1.warn_on_verify?)

    quote generated: true do
      def __verify_route__(unquote(path)) do
        {unquote(forward_plug), unquote(warn_on_verify?)}
      end
    end
  end

  defp build_match({route, expr}, {acc_pipes, known_pipes}) do
    {pipe_name, acc_pipes, known_pipes} = build_match_pipes(route, acc_pipes, known_pipes)

    %{
      prepare: prepare,
      dispatch: dispatch,
      verb_match: verb_match,
      path_params: path_params,
      hosts: hosts,
      path: path
    } = expr

    clauses =
      for host <- hosts do
        quote line: route.line do
          def __match_route__(unquote(path), unquote(verb_match), unquote(host)) do
            {unquote(build_metadata(route, path_params)),
             fn var!(conn, :conn), %{path_params: var!(path_params, :conn)} ->
               unquote(prepare)
             end, &(unquote(Macro.var(pipe_name, __MODULE__)) / 1), unquote(dispatch)}
          end
        end
      end

    {clauses, {acc_pipes, known_pipes}}
  end

  defp build_match_pipes(route, acc_pipes, known_pipes) do
    %{pipe_through: pipe_through} = route

    case known_pipes do
      %{^pipe_through => name} ->
        {name, acc_pipes, known_pipes}

      %{} ->
        name = :"__pipe_through#{map_size(known_pipes)}__"
        acc_pipes = [build_pipes(name, pipe_through) | acc_pipes]
        known_pipes = Map.put(known_pipes, pipe_through, name)
        {name, acc_pipes, known_pipes}
    end
  end

  defp build_metadata(route, path_params) do
    %{
      path: path,
      plug: plug,
      plug_opts: plug_opts,
      pipe_through: pipe_through,
      metadata: metadata
    } = route

    pairs = [
      conn: nil,
      route: path,
      plug: plug,
      plug_opts: Macro.escape(plug_opts),
      path_params: path_params,
      pipe_through: pipe_through
    ]

    {:%{}, [], pairs ++ Macro.escape(Map.to_list(metadata))}
  end

  defp build_pipes(name, []) do
    quote do
      defp unquote(name)(conn), do: conn
    end
  end

  defp build_pipes(name, pipe_through) do
    plugs = pipe_through |> Enum.reverse() |> Enum.map(&{&1, [], true})
    opts = [init_mode: plug_init_mode(), log_on_halt: :debug]
    {conn, body} = Plug.Builder.compile(__ENV__, plugs, opts)

    quote do
      defp unquote(name)(unquote(conn)), do: unquote(body)
    end
  end

  defmacro __before_compile__(env) do
    routes = env.module |> Module.get_attribute(:restapi_routes) |> Enum.reverse()
    forwards = env.module |> Module.get_attribute(:restapi_forwards)
    routes_with_exprs = Enum.map(routes, &{&1, Route.exprs(&1, forwards)})

    helpers =
      if Module.get_attribute(env.module, :restapi_helpers) do
        # Helpers.define(env, routes_with_exprs)
      end

    {matches, {pipelines, _}} =
      Enum.map_reduce(routes_with_exprs, {[], %{}}, &build_match/2)

    routes_per_path =
      routes_with_exprs
      |> Enum.group_by(&elem(&1, 1).path, &elem(&1, 0))

    verifies =
      routes_with_exprs
      |> Enum.map(&elem(&1, 1).path)
      |> Enum.uniq()
      |> Enum.map(&build_verify(&1, routes_per_path))

    verify_catch_all =
      quote generated: true do
        @doc false
        def __verify_route__(_path_info) do
          :error
        end
      end

    match_catch_all =
      quote generated: true do
        @doc false
        def __match_route__(_path_info, _verb, _host) do
          :error
        end
      end

    forwards =
      for {plug, script_name} <- forwards do
        quote do
          def __forward__(unquote(plug)), do: unquote(script_name)
        end
      end

    forward_catch_all =
      quote generated: true do
        @doc false
        def __forward__(_), do: nil
      end

    checks =
      routes
      |> Enum.uniq_by(&{&1.line, &1.plug})
      |> Enum.map(fn %{line: line, plug: plug} ->
        quote line: line, do: _ = &unquote(plug).init/1
      end)

    keys = [:verb, :path, :plug, :plug_opts, :helper, :metadata]
    routes = Enum.map(routes, &Map.take(&1, keys))

    quote do
      @doc false
      def __routes__, do: unquote(Macro.escape(routes))

      @doc false
      def __checks__, do: unquote({:__block__, [], checks})

      @doc false
      def __helpers__, do: unquote(helpers)

      defp prepare(conn) do
        merge_private(conn, [{:restapi_router, __MODULE__}, {__MODULE__, conn.script_name}])
      end

      unquote(pipelines)
      unquote(verifies)
      unquote(verify_catch_all)
      unquote(matches)
      unquote(match_catch_all)
      unquote(forwards)
      unquote(forward_catch_all)
    end
  end

  defp match_dispatch() do
    quote location: :keep, generated: true do
      @behaviour Plug

      @doc """
      Callback required by Plug that initializes the router
      for serving web requests.
      """
      def init(opts) do
        opts
      end

      @doc """
      Callback invoked by Plug on every request.
      """
      def call(conn, _opts) do
        %{method: method, path_info: path_info, host: host} = conn = prepare(conn)

        # TODO: Remove try/catch on Elixir v1.13 as decode no longer raises
        decoded =
          try do
            Enum.map(path_info, &URI.decode/1)
          rescue
            ArgumentError ->
              raise MalformedURIError, "malformed URI path: #{inspect(conn.request_path)}"
          end

        case __match_route__(decoded, method, host) do
          {metadata, prepare, pipeline, plug_opts} ->
            RestAPI.Router.__call__(conn, metadata, prepare, pipeline, plug_opts)

          :error ->
            raise NoRouteError, conn: conn, router: __MODULE__
        end
      end

      defoverridable init: 1, call: 2
    end
  end

  defp prelude() do
    quote do
      Module.register_attribute(__MODULE__, :restapi_routes, accumulate: true)
      @restapi_forwards %{}

      import RestAPI.Router

      # TODO v2: No longer automatically import dependencies
      import Plug.Conn

      # Set up initial scope
      @restapi_pipeline nil
      RestAPI.Router.Scope.init(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defp expand_alias({:__aliases__, _, _} = alias, env),
    do: Macro.expand(alias, %{env | function: {:init, 1}})

  defp expand_alias(other, _env), do: other

  defmacro scope(options, do: context) do
    options =
      if Macro.quoted_literal?(options) do
        Macro.prewalk(options, &expand_alias(&1, __CALLER__))
      else
        options
      end

    do_scope(options, context)
  end

  defmacro scope(path, options, do: context) do
    options =
      if Macro.quoted_literal?(options) do
        Macro.prewalk(options, &expand_alias(&1, __CALLER__))
      else
        options
      end

    options =
      quote do
        path = unquote(path)

        case unquote(options) do
          alias when is_atom(alias) -> [path: path, alias: alias]
          options when is_list(options) -> Keyword.put(options, :path, path)
        end
      end

    do_scope(options, context)
  end

  defmacro scope(path, alias, options, do: context) do
    alias = expand_alias(alias, __CALLER__)

    options =
      quote do
        unquote(options)
        |> Keyword.put(:path, unquote(path))
        |> Keyword.put(:alias, unquote(alias))
      end

    do_scope(options, context)
  end

  defp do_scope(options, context) do
    quote do
      Scope.push(__MODULE__, unquote(options))

      try do
        unquote(context)
      after
        Scope.pop(__MODULE__)
      end
    end
  end

  def __call__(
        %{private: %{restapi_router: router, restapi_bypass: {router, pipes}}} = conn,
        metadata,
        prepare,
        pipeline,
        _
      ) do
    conn = prepare.(conn, metadata)

    case pipes do
      :current -> pipeline.(conn)
      _ -> Enum.reduce(pipes, conn, fn pipe, acc -> apply(router, pipe, [acc, []]) end)
    end
  end

  def __call__(%{private: %{restapi_bypass: :all}} = conn, metadata, prepare, _, _) do
    prepare.(conn, metadata)
  end

  def __call__(conn, metadata, prepare, pipeline, {plug, opts}) do
    conn = prepare.(conn, metadata)
    start = System.monotonic_time()
    measurements = %{system_time: System.system_time()}
    metadata = %{metadata | conn: conn}
    :telemetry.execute([:restapi, :router_dispatch, :start], measurements, metadata)

    case pipeline.(conn) do
      %Plug.Conn{halted: true} = halted_conn ->
        measurements = %{duration: System.monotonic_time() - start}
        metadata = %{metadata | conn: halted_conn}
        :telemetry.execute([:restapi, :router_dispatch, :stop], measurements, metadata)
        halted_conn

      %Plug.Conn{} = piped_conn ->
        try do
          plug.call(piped_conn, plug.init(opts))
        else
          conn ->
            measurements = %{duration: System.monotonic_time() - start}
            metadata = %{metadata | conn: conn}
            :telemetry.execute([:restapi, :router_dispatch, :stop], measurements, metadata)
            conn
        rescue
          e in Plug.Conn.WrapperError ->
            measurements = %{duration: System.monotonic_time() - start}
            new_metadata = %{conn: conn, kind: :error, reason: e, stacktrace: __STACKTRACE__}
            metadata = Map.merge(metadata, new_metadata)
            :telemetry.execute([:restapi, :router_dispatch, :exception], measurements, metadata)
            Plug.Conn.WrapperError.reraise(e)
        catch
          kind, reason ->
            measurements = %{duration: System.monotonic_time() - start}
            new_metadata = %{conn: conn, kind: kind, reason: reason, stacktrace: __STACKTRACE__}
            metadata = Map.merge(metadata, new_metadata)
            :telemetry.execute([:restapi, :router_dispatch, :exception], measurements, metadata)
            Plug.Conn.WrapperError.reraise(piped_conn, kind, reason, __STACKTRACE__)
        end
    end
  end
end
