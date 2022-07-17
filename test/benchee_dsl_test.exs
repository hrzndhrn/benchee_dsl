defmodule BencheeDslTest do
  use ExUnit.Case

  import ExUnit.{CaptureLog, CaptureIO}
  import Mox

  require Logger

  alias BencheeDsl.BencheeMock

  @benchee_run Application.get_env(:benchee_dsl, :benchee_run)

  setup :verify_on_exit!

  setup do
    :sys.replace_state(BencheeDsl.Server, fn _ ->
      %{benchmarks: %{}, config: []}
    end)

    :ok
  end

  test "runs benchmark for basic_bench.exs and add config" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)
      assert Keyword.equal?(config, formatters: [Benchee.Formatters.Console])

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/basic_bench.exs")
  end

  test "runs benchmark with BasicBench.run/1" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)
      assert Keyword.equal?(config, [])

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/basic_bench.exs", BasicBench)
  end

  test "runs benchmark with Benchmark.One.run/1 and ignores Bencmark.Two" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"one_one" => one, "one_two" => two} = jobs
      assert is_function(one, 0)
      assert is_function(two, 0)
      assert Keyword.equal?(config, [])

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/benchmarks.exs", Benchmark.One)
  end

  test "runs benchmark for config_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)

      assert Keyword.equal?(config, [
               {:formatters, [Benchee.Formatters.Console]},
               {:time, 3},
               {:parallel, 2}
             ])

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/config_bench.exs")
  end

  test "runs benchmark for inputs_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 1)
      assert is_function(map_flatten, 1)

      assert Keyword.equal?(config,
               formatters: [Benchee.Formatters.Console],
               inputs: %{
                 "Small" => Enum.to_list(1..1_000),
                 "Medium" => Enum.to_list(1..10_000),
                 "Bigger" => Enum.to_list(1..100_000)
               },
               time: 1
             )

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/inputs_bench.exs")
  end

  test "runs benchmark for inputs_fun_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map_flatten" => map_flatten} = jobs
      assert is_function(flat_map, 1)
      assert is_function(map_flatten, 1)

      assert Keyword.equal?(config,
               inputs: %{
                 "Small" => Enum.to_list(1..1_000),
                 "Medium" => Enum.to_list(1..10_000),
                 "Bigger" => Enum.to_list(1..100_000)
               },
               formatters: [Benchee.Formatters.Console]
             )

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/inputs_fun_bench.exs")
  end

  test "runs benchmark for attr_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)

      assert Keyword.equal?(config, [{:formatters, [Benchee.Formatters.Console]}, time: 3])

      benchee_run(jobs, config)
    end)

    BencheeDsl.config(
      file: "test/fixtures/attr_bench.exs",
      before_each_benchmark: fn benchmark ->
        assert benchmark |> Map.keys() |> Enum.sort() ==
                 [:__struct__, :config, :description, :dir, :module, :title]

        assert %{
                 config: config,
                 module: module,
                 dir: dir,
                 title: title,
                 description: description
               } = benchmark

        assert Keyword.equal?(config, formatters: [Benchee.Formatters.Console])
        assert module == AttrBench
        assert String.ends_with?(dir, "benchee_dsl/test/fixtures")
        assert title == "title"
        assert description == "description"

        Map.update!(benchmark, :config, fn config -> Keyword.put(config, :time, 3) end)
      end
    )

    assert capture_io(fn ->
             assert BencheeDsl.run()
           end) == "Run: test/fixtures/attr_bench.exs\n\n"
  end

  test "runs benchmark for setup_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"do_it" => do_it} = jobs
      assert is_function(do_it, 0)

      assert Keyword.equal?(config,
               formatters: [Benchee.Formatters.Console],
               time: 1
             )

      benchee_run(jobs, config)
    end)

    assert BencheeDsl.config(file: "test/fixtures/setup_bench.exs")

    log =
      capture_log(fn ->
        capture_io(fn ->
          assert BencheeDsl.run()
        end)

        Logger.flush()
      end)

    assert log =~ "Hello, world"
    assert log =~ "Good bye, world"
  end

  test "runs benchmark for formatter_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      path = "test/fixtures/formatter.md"

      assert %{"do_it" => do_it} = jobs
      assert is_function(do_it, 0)

      assert config[:time] == 1
      assert [{formatter, formatter_config}, console] = config[:formatters]
      assert formatter == Benchee.Formatters.Markdown
      assert String.ends_with?(formatter_config[:file], path)
      assert formatter_config[:description] == "Bla bla bla ...\n"
      assert console == Benchee.Formatters.Console

      if @benchee_run do
        assert(Benchee.run(jobs, config))
        File.exists?(path)
        File.rm(path)
      end
    end)

    assert_run("test/fixtures/formatter_bench.exs")
  end

  test "runs function before_each_benchmark" do
    expect(BencheeMock, :run, 3, fn jobs, config ->
      assert %{"do_it" => do_it} = jobs
      assert is_function(do_it, 0)

      benchee_run(jobs, config)
    end)

    assert BencheeDsl.config(
             path: "test/fixtures/math",
             before_each_benchmark: fn benchmark ->
               assert Enum.member?(
                        [Math.AddBench, Math.SubBench, Math.Complex.AddBench],
                        benchmark.module
                      )

               benchmark
             end
           )

    assert capture_io(fn ->
             assert BencheeDsl.run()
           end) == """
           Run: test/fixtures/math/add_bench.exs

           Run: test/fixtures/math/complex/add_bench.exs

           Run: test/fixtures/math/sub_bench.exs

           """
  end

  test "runs benchmark for delegate_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert jobs |> Map.keys() |> Enum.sort() == ["Foo.Bar.Baz.flat_map", "flat_map", "mf"]

      assert(
        %{
          "Foo.Bar.Baz.flat_map" => foo_bar_baz,
          "flat_map" => flat_map,
          "mf" => map_flatten
        } = jobs
      )

      assert is_function(foo_bar_baz, 1)
      assert is_function(flat_map, 1)
      assert is_function(map_flatten, 1)

      assert Keyword.equal?(config,
               inputs: %{"bigger" => [1, 100_000], "medium" => [1, 10_000], "small" => [1, 100]},
               formatters: [Benchee.Formatters.Console]
             )

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/delegate_bench.exs")
  end

  test "runs benchmark for delegate__without_input_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert jobs |> Map.keys() |> Enum.sort() == ["flat_map", "map_flatten"]

      assert %{
               "flat_map" => flat_map,
               "map_flatten" => map_flatten
             } = jobs

      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)

      assert Keyword.equal?(config, formatters: [Benchee.Formatters.Console])

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/delegate_without_input_bench.exs")
  end

  test "runs benchmark for jobs_override_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"map" => map} = jobs
      assert is_function(map, 0)

      assert Keyword.equal?(config, formatters: [Benchee.Formatters.Console], time: 1)

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/jobs_override_bench.exs")
  end

  test "runs benchmark for jobs_update_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{"map" => map, "add" => add} = jobs
      assert is_function(map, 0)
      assert is_function(add, 0)

      assert Keyword.equal?(config, formatters: [Benchee.Formatters.Console], time: 1)

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/jobs_update_bench.exs")
  end

  test "runs benchmark for hooks_bench.exs" do
    expect(BencheeMock, :run, fn jobs, config ->
      assert %{
               "flat_map" => {flat_map, flat_map_hooks},
               "map_flatten" => {map_flatten, map_flatten_hooks}
             } = jobs

      assert is_function(flat_map, 1)
      assert is_function(flat_map_hooks[:before_scenario], 1)
      assert flat_map_hooks[:before_scenario].([1, 2]) == 1..2
      assert is_function(flat_map_hooks[:before_each], 1)
      assert flat_map_hooks[:before_each].(:in) == :in
      assert is_function(flat_map_hooks[:after_scenario], 1)
      assert is_function(flat_map_hooks[:after_each], 1)

      assert is_function(map_flatten, 1)
      assert is_function(map_flatten_hooks[:before_scenario], 1)
      assert map_flatten_hooks[:before_scenario].(:in) == :in
      assert is_function(map_flatten_hooks[:before_each], 1)
      assert map_flatten_hooks[:before_each].(:in) == :in
      assert is_function(map_flatten_hooks[:after_scenario], 1)
      assert is_function(map_flatten_hooks[:after_each], 1)

      benchee_run(jobs, config)
    end)

    assert_run("test/fixtures/hooks_bench.exs")
  end

  defp assert_run(file) do
    assert BencheeDsl.config(file: file)

    output =
      capture_io(fn ->
        assert BencheeDsl.run()
      end)

    assert String.starts_with?(output, "Run: #{file}")
  end

  defp assert_run(file, module) do
    Code.compile_file(file)

    capture_io(fn ->
      assert module.run() == :ok
    end)
  end

  defp benchee_run(jobs, config) do
    if @benchee_run, do: assert(Benchee.run(jobs, config))
  end
end
