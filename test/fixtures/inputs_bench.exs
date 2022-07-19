defmodule InputsBench do
  use BencheeDsl.Benchmark

  inputs %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }

  config time: 1

  map_fun = fn i -> [i, i * i] end

  job flat_map(input) do
    Enum.flat_map(input, map_fun)
  end

  job "map.flatten", input do
    input |> Enum.map(map_fun) |> List.flatten()
  end
end
