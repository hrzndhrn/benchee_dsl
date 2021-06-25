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

  def map_fun(i), do: [i, i * i]

  defp data(range), do: Enum.to_list(range)

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
