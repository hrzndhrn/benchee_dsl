defmodule GlobalHooksBench do
  use BencheeDsl.Benchmark

  require Logger

  config warmup: 0, time: 1

  inputs %{
    a: 1..10,
    b: 1..100
  }

  before_scenario(input, do: input)

  before_each(input, do: input)

  after_each(input, do: input)

  after_scenario(input, do: input)

  job do_it(input), do: Enum.map(input, fn value -> value * value end)

  job make_it(input), do: Enum.map(input, fn value -> value * value end)
end
