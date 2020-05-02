defmodule BasicBench do
  use BencheeDsl

  inputs %{
    "Small" => [Enum.to_list(1..1_000)],
    "Medium" => [Enum.to_list(1..10_000)],
    "Bigger" => [Enum.to_list(1..100_000)]
  }

  job flat_map(input) do
    Enum.flat_map(input, map_fun) end,
  end

  job map_flatten(input) do
    input |> Enum.map(map_fun) |> List.flatten() end
  end


  def map_fun(), do: fn i -> [i, i * i]
end
