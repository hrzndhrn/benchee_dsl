defmodule ConfigBench do
  use BencheeDsl.Benchmark

  @list Enum.to_list(1..10_000)

  defp map_fun(i), do: [i, i * i]

  config time: 3, parallel: 2

  job flat_map do
    Enum.flat_map(@list, &map_fun/1)
  end

  job "map.flatten" do
    @list |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
