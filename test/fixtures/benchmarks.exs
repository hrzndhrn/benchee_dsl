defmodule Benchmark.One do
  use BencheeDsl.Benchmark

  job one_one, do: :one

  job one_two, do: :two
end

defmodule Benchmark.Two do
  use BencheeDsl.Benchmark

  job two_one, do: :one

  job two_two, do: :two
end
