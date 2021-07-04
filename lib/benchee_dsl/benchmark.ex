defmodule BencheeDsl.Benchmark do
  @moduledoc """
  Helpers for defining a benchmark with the DSL.

  This module must be used to define and configure a benchmark.
  """

  alias BencheeDsl.Server

  @keys [
    :config,
    :description,
    :dir,
    :module,
    :title
  ]

  @type keys ::
          :config
          | :description
          | :dir
          | :module
          | :title

  @type t :: %__MODULE__{
          config: keyword(),
          description: String.t(),
          dir: String.t(),
          module: module(),
          title: String.t()
        }

  defstruct @keys

  @doc """
  Creates a new `Benchmark` struct.
  """
  @spec new(keyword()) :: t()
  def new(data), do: struct!(__MODULE__, data)

  @doc """
  Updates a `benchmark` struct by the given `key` or `path`.
  """
  @spec update(t(), keys() | list(atom()), (any() -> any())) :: t()
  def update(benchmark, key, fun) when key in @keys do
    Map.update!(benchmark, key, fun)
  end

  def update(benchmark, [key | path], fun) when key in @keys do
    Map.update!(benchmark, key, fn data ->
      update_in(data, path, fun)
    end)
  end

  defmacro __using__(_opts) do
    quote do
      import BencheeDsl.Benchmark

      Module.register_attribute(__MODULE__, :title, persist: true)
      Module.register_attribute(__MODULE__, :description, persist: true)

      Module.register_attribute(__MODULE__, :tag, accumulate: true)
      Module.register_attribute(__MODULE__, :before, persist: true)

      Module.register_attribute(__MODULE__, :__dir__, persist: true)
      Module.put_attribute(__MODULE__, :__dir__, __DIR__)

      Module.register_attribute(__MODULE__, :__file__, persist: true)
      Module.put_attribute(__MODULE__, :__file__, __ENV__.file)
    end
  end

  @doc """
  Defines a `setup` callback to be run before the benchmark starts.
  """
  defmacro setup(do: body) do
    quote do
      def setup, do: unquote(body)
    end
  end

  @doc """
  Defines a callback that runs once the benchmark exits.
  """
  defmacro on_exit(fun) do
    quote do
      Server.register(:on_exit, __MODULE__, unquote(fun))
    end
  end

  @doc """
  Overwrites the job map. This function can be used to set up jobs dynamically.
  """
  defmacro jobs(do: body) do
    quote do
      def jobs, do: unquote(body)
    end
  end

  @doc """
  Updates the job map. This function can be used to set up jobs dynamically.
  """
  defmacro jobs(var, do: body) do
    quote do
      def jobs(unquote(var)), do: unquote(body)
    end
  end

  @doc """
  Defines a function or `map` to setup the inputs for the benchmark. If inputs
  has a `do` block a `map` is expected to be returned.
  """
  defmacro inputs(do: inputs) do
    quote do
      def inputs, do: unquote(inputs)
    end
  end

  defmacro inputs(inputs) do
    quote do
      def inputs, do: unquote(inputs)
    end
  end

  @doc """
  Configures the benchmark.
  """
  defmacro config(config) do
    quote do
      Server.register(:config, __MODULE__, unquote(config))
    end
  end

  @doc """
  This macro defines a function for the benchmark.
  """
  defmacro job({:&, _, [{:/, _, [{_, _, _} = fun_name, arity]}]} = fun) do
    # The `String.trim_trailing/2` is needed for older Elixir versions.
    quote_job_apply(fun_name |> Macro.to_string() |> String.trim_trailing("()"), fun, arity)
  end

  defmacro job({:&, _, [{:/, _, [{_, _, _}, arity]}]} = fun, as: as) do
    quote_job_apply(as, fun, arity)
  end

  defmacro job({fun_name, _, nil}, do: body) do
    quote_job(fun_name, body)
  end

  defmacro job({fun_name, _, [var]}, do: body) do
    quote_job(fun_name, var, body)
  end

  defmacro job(fun_name, do: body) do
    quote_job(fun_name, do: body)
  end

  defmacro job(fun_name, var, do: body) when is_binary(fun_name) do
    quote_job(fun_name, var, body)
  end

  defp quote_job(fun_name, var, body) do
    quote do
      Server.register(:job, __MODULE__, unquote(fun_name),
        tags: Module.delete_attribute(__MODULE__, :tag),
        before: Module.delete_attribute(__MODULE__, :before)
      )

      def job(unquote(fun_name)) do
        fn unquote(var) -> unquote(body) end
      end
    end
  end

  defp quote_job(fun_name, body) do
    quote do
      Server.register(:job, __MODULE__, unquote(fun_name),
        tags: Module.delete_attribute(__MODULE__, :tag),
        before: Module.delete_attribute(__MODULE__, :before)
      )

      def job(unquote(fun_name)) do
        fn -> unquote(body) end
      end
    end
  end

  defp quote_job_apply(fun_name, body, 0) do
    quote do
      Server.register(:job, __MODULE__, unquote(fun_name),
        tags: Module.delete_attribute(__MODULE__, :tag),
        before: Module.delete_attribute(__MODULE__, :before)
      )

      def job(unquote(fun_name)) do
        fn -> apply(unquote(body), []) end
      end
    end
  end

  defp quote_job_apply(fun_name, body, _arity) do
    quote do
      Server.register(:job, __MODULE__, unquote(fun_name),
        tags: Module.delete_attribute(__MODULE__, :tag),
        before: Module.delete_attribute(__MODULE__, :before)
      )

      def job(unquote(fun_name)) do
        fn input -> apply(unquote(body), input) end
      end
    end
  end

  @doc """
  Adds a formatter to the benchmark.
  """
  defmacro formatter(module, opts) do
    quote do
      Server.register(:formatter, __MODULE__, {unquote(module), unquote(opts)})
    end
  end
end
