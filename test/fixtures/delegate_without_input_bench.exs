defmodule Bar do
  @list Enum.to_list(1..100)
  def flat_map, do: Enum.flat_map(@list, &map_fun/1)

  def map_flatten, do: @list |> Enum.map(&map_fun/1) |> List.flatten()

  defp map_fun(i), do: [i, i * i]
end

defmodule DelegateWithoutInputBench do
  use BencheeDsl.Benchmark

  import Bar

  job &flat_map/0

  job &map_flatten/0
end
