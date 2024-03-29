defmodule BencheeDsl.Runner do
  @moduledoc false

  alias BencheeDsl.Benchmark

  def run(module, opts, config, dsl_config, %{run: :iex} = cli_args) do
    opts = Map.update(opts, :config, [], fn opts_config -> Keyword.merge(opts_config, config) end)

    case included?(module, cli_args) do
      true -> {:ok, run(module, opts, config, dsl_config)}
      false -> :error
    end
  end

  def run(module, opts, config, dsl_config, cli_args) do
    file = get_attr(module, :__file__)

    case included?(module, cli_args) do
      true ->
        IO.write("Run: #{Path.relative_to_cwd(file)}\n")
        {:ok, run(module, opts, config, dsl_config)}
        IO.write("\n")

      false ->
        IO.write("Exclude: #{Path.relative_to_cwd(file)}\n")
        :error
    end
  end

  defp run(module, opts, config, dsl_config) do
    %{config: config} =
      opts
      |> config(config, module)
      |> benchmark(module)
      |> before_each_benchmark(dsl_config)

    jobs = jobs(opts)

    if function_exported?(module, :setup, 0), do: module.setup()

    Application.get_env(:benchee_dsl, :benchee).run(jobs, config)
  end

  defp included?(module, %{include: include}) when is_atom(include) do
    module == include
  end

  defp included?(module, %{include: include}) when is_binary(include) do
    module |> get_attr(:__file__) |> String.ends_with?(include)
  end

  defp included?(_module, _cli_args), do: true

  defp config(opts, config, module) do
    config
    |> Keyword.merge(Map.get(opts, :config, []))
    |> inputs(module)
    |> formatters(Map.get(opts, :formatters, []))
  end

  defp before_each_benchmark(benchmark, config) do
    case Keyword.fetch(config, :before_each_benchmark) do
      :error -> benchmark
      {:ok, fun} -> fun.(benchmark)
    end
  end

  defp inputs(config, module) do
    case function_exported?(module, :inputs, 0) do
      true -> Keyword.put(config, :inputs, module.inputs())
      false -> config
    end
  end

  defp formatters(config, []), do: config

  defp formatters(config, formatters) do
    Keyword.update(config, :formatters, formatters, &merge_formatters(&1, formatters))
  end

  defp merge_formatters(formatters, []), do: formatters

  defp merge_formatters(formatters_a, [formatter_b | formatters_b]) do
    formatters_a
    |> Enum.find_index(fn formatter_a ->
      same_formatter(formatter_a, formatter_b)
    end)
    |> case do
      nil ->
        merge_formatters([formatter_b | formatters_a], formatters_b)

      index ->
        merge_formatters(List.replace_at(formatters_a, index, formatter_b), formatters_b)
    end
  end

  defp same_formatter({a, _}, {b, _}), do: a == b

  defp same_formatter(a, {b, _}), do: a == b

  defp same_formatter({a, _}, b), do: a == b

  defp same_formatter(a, b), do: a == b

  defp benchmark(config, module) do
    title = get_attr(module, :title)
    config = if title != nil, do: Keyword.put(config, :title, title), else: config

    Benchmark.new(
      dir: get_attr(module, :__dir__),
      module: module,
      config: config,
      description: get_attr(module, :description)
    )
  end

  defp get_attr(nil), do: nil

  defp get_attr([value]), do: value

  defp get_attr(module, key), do: get_attr(module.__info__(:attributes)[key])

  defp jobs(%{jobs: jobs}) do
    Enum.reduce(jobs, %{}, fn {job, opts}, acc ->
      tags = Keyword.get(opts, :tags)
      name = to_string(job)
      fun = job_fun(opts)
      job_opts = job_opts(opts)

      case {Enum.member?(tags, :skip), job_opts} do
        {true, _} -> acc
        {false, []} -> Map.put(acc, name, fun)
        {false, job_opts} -> Map.put(acc, name, {fun, job_opts})
      end
    end)
  end

  defp jobs(_), do: %{}

  defp job_fun(opts) do
    case Keyword.has_key?(opts, :fun) do
      true -> Keyword.fetch!(opts, :fun)
      false -> opts |> Keyword.fetch!(:mfa) |> capture()
    end
  end

  defp capture({m, f, a}), do: Function.capture(m, f, a)

  defp job_opts(opts) do
    []
    |> local_hooks(opts, :before_scenario)
    |> local_hooks(opts, :before_each)
    |> local_hooks(opts, :after_scenario)
    |> local_hooks(opts, :after_each)
  end

  defp local_hooks(hooks, opts, key) do
    case Keyword.get(opts, key) do
      nil -> hooks
      fun -> Keyword.put(hooks, key, hook(fun))
    end
  end

  defp hook(fun) do
    case Function.info(fun, :arity) do
      {:arity, 0} ->
        fn arg ->
          fun.()
          arg
        end

      {:arity, 1} ->
        fun
    end
  end
end
