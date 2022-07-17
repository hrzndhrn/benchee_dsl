defmodule GlobalHooksZeroBench do
  use BencheeDsl.Benchmark

  require Logger

  config warmup: 0, time: 1

  inputs %{
    a: 1..10,
    b: 1..100
  }

  before_scenario(do: :it)

  before_each(do: :it)

  after_each(do: :it)

  after_scenario(do: :it)

  job do_it(input), do: Enum.map(input, fn value -> value * value end)

  job make_it(input), do: Enum.map(input, fn value -> value * value end)
end
