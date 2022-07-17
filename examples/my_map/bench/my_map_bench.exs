defmodule MyMapBench do
  use BencheeDsl.Benchmark

  config memory_time: 2, pre_check: true

  after_each(do: :erlang.garbage_collect())

  inputs [
    {"Small (10 Thousand)", Enum.to_list(1..10_000)},
    {"Middle (100 Thousand)", Enum.to_list(1..100_000)},
    {"Big (1 Million)", Enum.to_list(1..1_000_000)},
    {"Bigger (5 Million)", Enum.to_list(1..5_000_000)},
    {"Giant (25 Million)", Enum.to_list(1..25_000_000)}
  ]

  defp map_fun(i), do: [i, i * i]

  job "tail-recursive", list do
    MyMap.map_tco(list, &map_fun/1)
  end

  job "stdlib map", list do
    Enum.map(list, &map_fun/1)
  end

  job "body-recursive", list do
    MyMap.map_body(list, &map_fun/1)
  end

  fn list -> MyMap.map_body(list, fn i -> [i, i * i] end) end |> Function.info() |> IO.inspect(label: :asdfasdf)

  job "tail-rec arg-order", list do
    MyMap.map_tco_arg_order(list, &map_fun/1)
  end
end
