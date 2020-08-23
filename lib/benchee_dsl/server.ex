defmodule BencheeDsl.Server do
  @moduledoc false

  use Agent

  alias BencheeDsl.Runner

  def start_link(opts) do
    initial = %{benchmarks: %{}, config: []}
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> initial end, name: name)
  end

  def run(config) do
    %{benchmarks: benchmarks, config: dsl_config} = Agent.get(__MODULE__, & &1)

    Enum.each(benchmarks, fn {module, opts} ->
      Runner.run(module, opts, config, dsl_config)
      on_exit(module)
    end)
  end

  def config, do: Agent.get(__MODULE__, fn %{config: config} -> config end)

  def on_exit(module) do
    %{benchmarks: benchmarks} = Agent.get(__MODULE__, & &1)
    benchmark = Map.fetch!(benchmarks, module)

    case Map.fetch(benchmark, :on_exit) do
      :error -> :ok
      {:ok, fun} -> fun.()
    end
  end

  def register(agent \\ __MODULE__, key, module, value)

  def register(agent, :config, module, config) do
    update_benchmarks(agent, module, %{config: config}, fn benchmarks ->
      Map.put(benchmarks, :config, config)
    end)
  end

  def register(agent, :on_exit, module, fun) do
    update_benchmarks(agent, module, %{on_exit: fun}, fn benchmarks ->
      Map.put(benchmarks, :on_exit, fun)
    end)
  end

  def register(agent, :job, module, job) do
    update_benchmarks(agent, module, %{jobs: [job]}, fn benchmarks ->
      Map.update(benchmarks, :jobs, [job], fn jobs -> [job | jobs] end)
    end)
  end

  def register(agent, :formatter, module, formatter) do
    update_benchmarks(agent, module, %{formatters: [formatter]}, fn benchmarks ->
      Map.update(benchmarks, :formatters, [formatter], fn formatters ->
        [formatter | formatters]
      end)
    end)
  end

  def register(:config, fun) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, :config, fun)
    end)
  end

  defp update_benchmarks(agent, module, initial, fun) do
    Agent.update(agent, fn %{benchmarks: benchmarks} = state ->
      Map.put(state, :benchmarks, Map.update(benchmarks, module, initial, fun))
    end)
  end
end
