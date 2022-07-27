defmodule AttrBench do
  use BencheeDsl.Benchmark

  @title "title"
  @description "description"

  @list Enum.to_list(1..10_000)

  defp map_fun(i), do: [i, i * i]

  job flat_map do
    Enum.flat_map(@list, &map_fun/1)
  end

  job "map.flatten" do
    @list |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
