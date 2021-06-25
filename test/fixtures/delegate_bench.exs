defmodule Foo do
  def flat_map(a, b) do
    a |> data(b) |> Enum.flat_map(&map_fun/1)
  end

  def map_flatten(a, b) do
    a |> data(b) |> Enum.map(&map_fun/1) |> List.flatten()
  end

  defp data(a, b), do: Enum.to_list(a..b)

  defp map_fun(i), do: [i, i * i]
end

defmodule DelegateBench do
  use BencheeDsl.Benchmark

  import Foo

  inputs %{
    "small" => [1, 100],
    "medium" => [1, 10_000],
    "bigger" => [1, 100_000]
  }

  job(&flat_map/2)

  job &map_flatten/2, as: :mf
end
