defmodule SetupBench do
  use BencheeDsl.Benchmark

  require Logger

  setup do
    name = "world"
    Logger.info("Hello, #{name}!")

    on_exit(fn ->
      Logger.info("Good bye, #{name}.")
    end)
  end

  config time: 1

  job do_it do
    1 + 1
  end
end
