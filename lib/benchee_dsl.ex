defmodule BencheeDsl do
  @moduledoc """
  TODO: Add moduledoc
  """

  alias BencheeDsl.Server

  @ending "_bench.exs"
  @default_config [formatters: [Benchee.Formatters.Console]]

  alias BencheeDsl.Server

  def run(config \\ []) do
    Server.config()
    |> path()
    |> benchmarks()
    |> Enum.each(&Code.require_file/1)

    config
    |> Keyword.merge(@default_config)
    |> Server.run()
  end

  def config(config), do: Server.register(:config, config)

  defp path(opts) do
    case Keyword.has_key?(opts, :file) do
      true -> {:file, opts[:file]}
      false -> {:path, opts[:path] || Application.get_env(:benchee_dsl, :path)}
    end
  end

  defp benchmarks(path, benchmarks \\ [])

  defp benchmarks({:file, file}, _), do: [file]

  defp benchmarks({:path, path}, benchmarks) do
    path
    |> File.ls!()
    |> Enum.reduce(benchmarks, fn item, acc ->
      path = Path.join(path, item)

      case File.dir?(path) do
        true ->
          benchmarks({:path, path}, acc)

        false ->
          add_benchmark(acc, path)
      end
    end)
  end

  defp add_benchmark(acc, path) do
    case String.ends_with?(path, @ending) do
      true -> [path | acc]
      false -> acc
    end
  end
end
