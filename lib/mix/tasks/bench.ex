defmodule Mix.Tasks.Bench do
  use Mix.Task

  @shortdoc "Start and runs the benchmarks"
  def run(_) do
    Application.ensure_all_started(:benchee_dsl) |> IO.inspect
    Code.compile_file("benchee_helper.exs", "bench") |> IO.inspect
  end
end
