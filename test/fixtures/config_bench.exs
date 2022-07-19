defmodule ConfigBench do
  use BencheeDsl.Benchmark

  list = Enum.to_list(1..10_000)

  map_fun = fn i -> [i, i * i] end

  config time: 3, parallel: 2

  job flat_map do
    Enum.flat_map(list, map_fun)
  end

  job "map.flatten" do
    list |> Enum.map(map_fun) |> List.flatten()
  end
end
