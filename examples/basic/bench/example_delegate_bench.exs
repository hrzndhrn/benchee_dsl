defmodule MyMap do
  def flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  def map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end

  defp map_fun(i), do: [i, i * i]
end

defmodule ExampleDelegateBench do
  use BencheeDsl.Benchmark

  config time: 6, memory_time: 2, pre_check: true

  inputs %{
    "Small" => [Enum.to_list(1..1_000)],
    "Medium" => [Enum.to_list(1..10_000)],
    "Bigger" => [Enum.to_list(1..100_000)]
  }

  # delegate to a function
  # job &MyMap.flat_map/1
  # job &MyMap.map_flatten/1

  # delegate to a module
  jobs MyMap
end
