defmodule InputsFunBench do
  use BencheeDsl.Benchmark

  inputs do
    small = data(1..1_000)
    medium = data(1..10_000)
    bigger = data(1..100_000)

    %{
      "Small" => small,
      "Medium" => medium,
      "Bigger" => bigger
    }
  end

  defp data(range), do: Enum.to_list(range)

  map_fun = fn i -> [i, i * i] end

  job flat_map(input) do
    Enum.flat_map(input, map_fun)
  end

  job map_flatten(input) do
    input |> Enum.map(map_fun) |> List.flatten()
  end
end
