defmodule Mix.Tasks.Bench do
  @moduledoc "Start and runs the benchmarks."

  use Mix.Task

  @shortdoc "Start and runs the benchmarks"
  def run(_) do
    Mix.Task.run "compile"
    Application.ensure_all_started(:benchee_dsl)
    Code.compile_file("benchee_helper.exs", "bench")
  end
end
