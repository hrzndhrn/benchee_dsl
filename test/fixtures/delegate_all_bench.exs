defmodule Foo do
  def flat_map(list) do
    Enum.flat_map(list, &map_fun/1)
  end

  def map_flatten(list) do
    list |> Enum.map(&map_fun/1) |> List.flatten()
  end

  defp map_fun(i), do: [i, i * i]
end

defmodule DelegateAllBench do
  use BencheeDsl.Benchmark

  config warmup: 0, time: 1

  inputs %{
    "small" => [Enum.to_list(1..100)],
    "medium" => [Enum.to_list(1..10_000)],
    "bigger" => [Enum.to_list(1..100_000)]
  }

  jobs Foo
end
