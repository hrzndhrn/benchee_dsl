defmodule InputsBench do
  use BencheeDsl.Benchmark

  inputs %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job "map.flatten", input do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
