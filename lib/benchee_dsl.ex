defmodule BencheeDsl do
  @moduledoc """
  A DSL for `Benchee`.
  """

  alias BencheeDsl.Server

  @ending "_bench.exs"
  @default_config [formatters: [Benchee.Formatters.Console]]

  @doc """
  Runs the benchmarks.
  """
  @spec run(keyword()) :: :ok
  def run(config \\ []) do
    Server.path()
    |> benchmarks()
    |> Enum.each(&Code.require_file/1)

    @default_config
    |> Keyword.merge(config)
    |> Server.run(cli_args())
  end

  @doc """
  Configures `benchee`.
  """
  @spec config(keyword()) :: :ok
  def config(config), do: Server.register(:config, config)

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

  defp cli_args do
    case Application.get_env(:benchee_dsl, :cli_args, []) do
      [benchmark] -> %{include: benchmark}
      _ -> %{}
    end
  end
end
