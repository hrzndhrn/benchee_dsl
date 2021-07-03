defmodule BencheeDsl.Server do
  @moduledoc false

  use Agent

  alias BencheeDsl.Runner

  def start_link(opts) do
    Agent.start_link(
      fn -> initial() end,
      name: Keyword.get(opts, :name, __MODULE__)
    )
  end

  def run(config, cli_args) do
    %{benchmarks: benchmarks, config: dsl_config} = Agent.get(__MODULE__, & &1)

    Enum.each(benchmarks, fn {module, opts} ->
      Runner.run(module, opts, config, dsl_config, cli_args)
      on_exit(module)
    end)
  end

  def config, do: Agent.get(__MODULE__, fn %{config: config} -> config end)

  def path do
    opts = config()

    case Keyword.has_key?(opts, :file) do
      true -> {:file, opts[:file]}
      false -> {:path, opts[:path] || Application.get_env(:benchee_dsl, :path)}
    end
  end

  def on_exit(module) do
    %{benchmarks: benchmarks} = Agent.get(__MODULE__, & &1)
    benchmark = Map.fetch!(benchmarks, module)

    case Map.fetch(benchmark, :on_exit) do
      :error -> :ok
      {:ok, fun} -> fun.()
    end
  end

  def register(:config, fun) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, :config, fun)
    end)
  end

  def register(:config, module, config) do
    update_benchmarks(__MODULE__, module, %{config: config}, fn benchmarks ->
      Map.put(benchmarks, :config, config)
    end)
  end

  def register(:on_exit, module, fun) do
    update_benchmarks(__MODULE__, module, %{on_exit: fun}, fn benchmarks ->
      Map.put(benchmarks, :on_exit, fun)
    end)
  end

  def register(:formatter, module, formatter) do
    update_benchmarks(__MODULE__, module, %{formatters: [formatter]}, fn benchmarks ->
      Map.update(benchmarks, :formatters, [formatter], fn formatters ->
        [formatter | formatters]
      end)
    end)
  end

  def register(:job, module, job, opts) do
    update_benchmarks(__MODULE__, module, %{jobs: [{job, opts}]}, fn benchmarks ->
      Map.update(benchmarks, :jobs, [{job, opts}], fn jobs -> [{job, opts} | jobs] end)
    end)
  end

  defp update_benchmarks(agent, module, initial, fun) do
    Agent.update(agent, fn %{benchmarks: benchmarks} = state ->
      Map.put(state, :benchmarks, Map.update(benchmarks, module, initial, fun))
    end)
  end

  defp initial do
    %{benchmarks: %{}, config: []}
  end
end
