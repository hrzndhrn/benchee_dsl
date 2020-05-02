defmodule BencheeDsl.Benchmark do
  @moduledoc """
  TODO: Add moduledoc
  """

  alias BencheeDsl.Server

  defmacro __using__(_opts) do
    quote do
      import BencheeDsl.Benchmark

      Module.register_attribute(__MODULE__, :title, persist: true)
      Module.register_attribute(__MODULE__, :description, persist: true)
      Module.register_attribute(__MODULE__, :__dir__, persist: true)
      Module.put_attribute(__MODULE__, :__dir__, __DIR__)
    end
  end

  defmacro setup_all(body) do
    quote do
      def setup_all, do: unquote(body)
    end
  end

  defmacro on_exit(fun) do
    quote do
      Server.register(:on_exit, __MODULE__, unquote(fun))
    end
  end

  defmacro inputs(do: inputs) do
    quote do
      Server.register(:inputs, __MODULE__, unquote(inputs))
    end
  end

  defmacro inputs(inputs) do
    quote do
      Server.register(:inputs, __MODULE__, unquote(inputs))
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
