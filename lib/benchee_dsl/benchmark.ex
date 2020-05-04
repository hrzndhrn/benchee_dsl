defmodule BencheeDsl.Benchmark do
  @moduledoc """
  Helpers for defining a benchmark with the DSL.
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
      Module.register_attribute(__MODULE__, :__dir__, persist: true)
      Module.put_attribute(__MODULE__, :__dir__, __DIR__)
    end
  end

  @doc """
  Defines a `setup` callback to be run before the benchmark starts.
  """
  defmacro setup(body) do
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

  defmacro config(config) do
    quote do
      Server.register(:config, __MODULE__, unquote(config))
    end
  end

  defmacro job({fun_name, _, nil}, do: body) do
    quote do
      Server.register(:job, __MODULE__, unquote(fun_name))

      def job(unquote(fun_name)) do
        fn -> unquote(body) end
      end
    end
  end

  defmacro job({fun_name, _, [var]}, do: body) do
    quote do
      Server.register(:job, __MODULE__, unquote(fun_name))

      def job(unquote(fun_name)) do
        fn unquote(var) -> unquote(body) end
      end
    end
  end

  defmacro job(fun_name, do: body) do
    quote do
      Server.register(:job, __MODULE__, unquote(fun_name))

      def job(unquote(fun_name)) do
        fn -> unquote(body) end
      end
    end
  end

  defmacro formatter(module, opts) do
    quote do
      Server.register(:formatter, __MODULE__, {unquote(module), unquote(opts)})
    end
  end
end
