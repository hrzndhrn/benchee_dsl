defmodule ExampleBench do
  use BencheeDsl.Benchmark

  config time: 6, memory_time: 2, pre_check: true

  inputs %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }

  defp map_fun(i), do: [i, i * i]

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
