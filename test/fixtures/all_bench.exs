defmodule Extra.AllBench do
  use BencheeDsl.Benchmark

  require Logger

  @title "All together now"

  setup_all do
    Logger.info("Hello!")

    on_exit(fn ->
      Logger.info("Good bye.")
    end)
  end

  config time: 5

  formatter(Benchee.Formatters.Markdown,
    file: Path.join("path/to", "bench.md"),
    description: """
    Bla bla bla ...
    """
  )

  inputs %{
    "Small" => [Enum.to_list(1..2)],
    "Medium" => [Enum.to_list(1..3)],
    "Bigger" => [Enum.to_list(1..4)]
  }

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
