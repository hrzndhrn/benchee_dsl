defmodule Mix.Tasks.Bench do
  @moduledoc "Start and runs the benchmarks."

  @dialyzer {:nowarn_function, run: 1}

  use Mix.Task

  @shortdoc "Start and runs the benchmarks"
  def run(_) do
    Mix.Task.run("compile", consolidate_protocols: true)
    Application.ensure_all_started(:benchee_dsl)
    Code.compile_file("benchee_helper.exs", "bench")
  end
end
