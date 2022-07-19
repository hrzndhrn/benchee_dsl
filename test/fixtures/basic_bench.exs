defmodule BasicBench do
  use BencheeDsl.Benchmark

  list = Enum.to_list(1..10_000)

  map_fun = fn i -> [i, i * i] end

  job flat_map, do: Enum.flat_map(list, map_fun)

  job "map.flatten", do: list |> Enum.map(map_fun) |> List.flatten()

  @tag :skip
  job foo2, do: 1 + 1
end
