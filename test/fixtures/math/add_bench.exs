defmodule Math.AddBench do
  use BencheeDsl.Benchmark

  config time: 1

  job do_it do
    1 + 1
  end
end
