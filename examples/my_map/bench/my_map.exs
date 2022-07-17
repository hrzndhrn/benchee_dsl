map_fun = fn i -> i + 1 end

inputs = [
  {"Small (10 Thousand)", Enum.to_list(1..10_000)},
  {"Middle (100 Thousand)", Enum.to_list(1..100_000)},
  {"Big (1 Million)", Enum.to_list(1..1_000_000)},
  {"Bigger (5 Million)", Enum.to_list(1..5_000_000)},
  {"Giant (25 Million)", Enum.to_list(1..25_000_000)}
]

Benchee.run(
  %{
    "tail-recursive" => fn list -> MyMap.map_tco(list, map_fun) end |> Function.info() |> IO.inspect(),
    "stdlib map" => fn list -> Enum.map(list, map_fun) end,
    "body-recursive" => fn list -> MyMap.map_body(list, map_fun) end,
    "tail-rec arg-order" => fn list -> MyMap.map_tco_arg_order(list, map_fun) end
  },
  memory_time: 2,
  inputs: inputs,
  formatters: [Benchee.Formatters.Console],
  after_each: fn _ -> :erlang.garbage_collect() end
)
