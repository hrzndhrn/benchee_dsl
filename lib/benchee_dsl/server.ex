defmodule BencheeDsl.Server do
  @moduledoc false

  use Agent

  alias BencheeDsl.Runner

  @agent BencheeDsl.Server

  def start_link(_opts) do
    Agent.start_link(
      fn -> initial() end,
      name: @agent
    )
  end

  defp initial, do: %{benchmarks: %{}, config: []}

  def run(config, cli_args) do
    Enum.each(benchmarks(), fn {module, opts} ->
      Runner.run(module, opts, config, config(), cli_args)
      on_exit(module)
    end)
  end

  def config do
    Agent.get(@agent, fn %{config: config} -> config end)
  end

  def benchmarks do
    Agent.get(@agent, fn %{benchmarks: benchmarks} -> benchmarks end)
  end

  def path do
    opts = config()

    case Keyword.has_key?(opts, :file) do
      true -> {:file, opts[:file]}
      false -> {:path, opts[:path] || Application.get_env(:benchee_dsl, :path)}
    end
  end

  def on_exit(module) do
    %{benchmarks: benchmarks} = Agent.get(@agent, & &1)
    benchmark = Map.fetch!(benchmarks, module)

    case Map.fetch(benchmark, :on_exit) do
      :error -> :ok
      {:ok, fun} -> fun.()
    end
  end

  def register(:config, fun) do
    Agent.update(@agent, fn state ->
      Map.put(state, :config, fun)
    end)
  end

  def register(:config, module, config) do
    update_benchmarks(@agent, module, %{config: config}, fn benchmarks ->
      Map.update(benchmarks, :config, config, fn conf -> Keyword.merge(conf, config) end)
    end)
  end

  def register(:on_exit, module, fun) do
    update_benchmarks(@agent, module, %{on_exit: fun}, fn benchmarks ->
      Map.put(benchmarks, :on_exit, fun)
    end)
  end

  def register(key, module, fun)
      when key in [:after_each, :after_scenario, :before_each, :before_scenario] do
    update_benchmarks(@agent, module, %{config: [{key, fun}]}, fn benchmarks ->
      Map.update(benchmarks, :config, [{key, fun}], fn config ->
        Keyword.put(config, key, fun)
      end)
    end)
  end

  def register(:formatter, module, formatter) do
    update_benchmarks(@agent, module, %{formatters: [formatter]}, fn benchmarks ->
      Map.update(benchmarks, :formatters, [formatter], fn formatters ->
        [formatter | formatters]
      end)
    end)
  end

  def register(:job, module, job, opts) do
    opts = update_local_hooks(opts)

    update_benchmarks(@agent, module, %{jobs: [{job, opts}]}, fn benchmarks ->
      Map.update(benchmarks, :jobs, [{job, opts}], fn jobs -> [{job, opts} | jobs] end)
    end)
  end

  defp update_benchmarks(agent, module, initial, fun) do
    Agent.update(agent, fn %{benchmarks: benchmarks} = state ->
      Map.put(state, :benchmarks, Map.update(benchmarks, module, initial, fun))
    end)
  end

  defp update_local_hooks(opts) do
    opts
    |> update_local_hook(:after_each)
    |> update_local_hook(:after_scenario)
    |> update_local_hook(:before_each)
    |> update_local_hook(:before_scenario)
  end

  defp update_local_hook(opts, key) do
    case Keyword.get(opts, key) do
      nil -> opts
      [] -> Keyword.delete(opts, key)
      [fun] when is_function(fun) -> Keyword.put(opts, key, fun)
      _invalid -> raise "Invalid local hook #{inspect(key)}"
    end
  end
end
