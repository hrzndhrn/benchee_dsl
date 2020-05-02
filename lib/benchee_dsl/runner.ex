defmodule BencheeDsl.Runner do
  @moduledoc false

  def run(module, opts, config, dsl_config) do
    if function_exported?(module, :setup_all, 0) do
      module.setup_all()
    end

    %{config: config} =
      opts
      |> config(config)
      |> benchmark(module)
      |> before_each_benchmark(dsl_config)

    jobs = jobs(module, opts)

    Application.get_env(:benchee_dsl, :benchee).run(jobs, config)
  end

  defp config(opts, config) do
    config
    |> Keyword.merge(Map.get(opts, :config, []))
    |> inputs(Map.get(opts, :inputs))
    |> formatters(Map.get(opts, :formatters, []))
  end

  defp before_each_benchmark(benchmark, config) do
    case Keyword.fetch(config, :before_each_benchmark) do
      :error -> benchmark
      {:ok, fun} -> fun.(benchmark)
    end
  end

  defp inputs(config, nil), do: config

  defp inputs(config, inputs), do: Keyword.put(config, :inputs, inputs)

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
    %{
      module: module,
      config: config,
      dir: get_attr(module, :__dir__),
      title: get_attr(module, :title),
      description: get_attr(module, :description)
    }
  end

  defp get_attr(nil), do: nil

  defp get_attr([value]), do: value

  defp get_attr(module, key), do: get_attr(module.__info__(:attributes)[key])

  defp jobs(module, %{jobs: jobs}) do
    Enum.into(jobs, %{}, fn job ->
      {to_string(job), module.job(job)}
    end)
  end
end