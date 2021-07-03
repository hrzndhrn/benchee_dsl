defmodule BeforeBench do
  use BencheeDsl.Benchmark

  inputs %{
    "Small" => [1, 1_000],
    "Medium" => [1, 10_000],
    "Bigger" => [1, 100_000]
  }

  config time: 1

  @before fn [from, to] -> from..to end
  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  @before fn -> :foo end
  job "map.flatten", [from, to] do
    from..to |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
