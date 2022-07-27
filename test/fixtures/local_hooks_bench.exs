defmodule LocalHooksBench do
  use BencheeDsl.Benchmark

  inputs %{
    "Tiny" => [1, 2],
    "Small" => [1, 5]
  }

  config time: 1, warmup: 0

  defp map_fun(i), do: [i, i * i]

  @before_scenario fn [from, to] -> from..to end
  @before_each fn input -> input end
  @after_scenario fn _result -> :on_exit end
  @after_each fn _result -> :on_exit_each end
  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  @before_scenario fn -> :foo end
  @before_each fn -> :foo end
  @after_scenario fn -> :on_exit end
  @after_each fn -> :on_exit_each end
  job map_flatten([from, to]) do
    from..to |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
