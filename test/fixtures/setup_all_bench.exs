defmodule SetupAllBench do
  use BencheeDsl.Benchmark

  require Logger

  setup_all do
    Logger.info("Hello!")

    on_exit(fn ->
      Logger.info("Good bye.")
    end)
  end

  config time: 1

  job do_it do
    1 + 1
  end
end
