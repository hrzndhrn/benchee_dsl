defmodule BeforeBench do
  use BencheeDsl.Benchmark

  inputs %{
    "Tiny" => [1, 2],
    "Small" => [1, 5]
  }

  config time: 1, warmup: 0

  @setup fn [from, to] -> from..to end
  @setup_each fn input -> input end
  @on_exit fn _result -> :on_exit end
  @on_exit_each fn _result -> :on_exit_each end
  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  @setup fn -> :foo end
  @setup_each fn -> :foo end
  @on_exit fn -> :on_exit end
  @on_exit_each fn -> :on_exit_each end
  job map_flatten([from, to]) do
    from..to |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
