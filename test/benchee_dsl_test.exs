defmodule BencheeDslTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Mox

  require Logger

  @benchee_run Application.get_env(:benchee_dsl, :benchee_run)

  setup do
    on_exit(fn ->
      verify!()

      :sys.replace_state(BencheeDsl.Server, fn _ ->
        %{benchmarks: %{}, config: []}
      end)
    end)
  end

  @tag :basic
  test "runs benchmark for basic_bench.exs" do
    BencheeDsl.BencheeMock
    |> expect(:run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)
      assert Keyword.equal?(config, formatters: [Benchee.Formatters.Console])

      if @benchee_run, do: assert(Benchee.run(jobs, config))
    end)

    assert BencheeDsl.config(file: "test/fixtures/basic_bench.exs")
    assert BencheeDsl.run()
  end

  @tag :config
  test "runs benchmark for config_bench.exs" do
    BencheeDsl.BencheeMock
    |> expect(:run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)

      assert Keyword.equal?(config, [
               {:formatters, [Benchee.Formatters.Console]},
               {:time, 3},
               {:parallel, 2}
             ])

      if @benchee_run, do: assert(Benchee.run(jobs, config))
    end)

    assert BencheeDsl.config(file: "test/fixtures/config_bench.exs")
    assert BencheeDsl.run()
  end

  @tag :inputs
  test "runs benchmark for inputs_bench.exs" do
    BencheeDsl.BencheeMock
    |> expect(:run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map_flatten" => map_flatten} = jobs
      assert is_function(flat_map, 1)
      assert is_function(map_flatten, 1)

      assert Keyword.equal?(config,
               formatters: [Benchee.Formatters.Console],
               inputs: %{
                 "Small" => Enum.to_list(1..1_000),
                 "Medium" => Enum.to_list(1..10_000),
                 "Bigger" => Enum.to_list(1..100_000)
               }
             )

      if @benchee_run, do: assert(Benchee.run(jobs, config))
    end)

    assert BencheeDsl.config(file: "test/fixtures/inputs_bench.exs")
    assert BencheeDsl.run()
  end

  @tag :inputs_fun
  test "runs benchmark for inputs_fun_bench.exs" do
    BencheeDsl.BencheeMock
    |> expect(:run, fn jobs, config ->
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

      if @benchee_run, do: assert(Benchee.run(jobs, config))
    end)

    assert BencheeDsl.config(file: "test/fixtures/inputs_fun_bench.exs")
    assert BencheeDsl.run()
  end

  @tag :attr
  test "runs benchmark for attr_bench.exs" do
    BencheeDsl.BencheeMock
    |> expect(:run, fn jobs, config ->
      assert %{"flat_map" => flat_map, "map.flatten" => map_flatten} = jobs
      assert is_function(flat_map, 0)
      assert is_function(map_flatten, 0)

      assert Keyword.equal?(config, [{:formatters, [Benchee.Formatters.Console]}, time: 3])

      if @benchee_run, do: assert(Benchee.run(jobs, config))
    end)

    BencheeDsl.config(
      file: "test/fixtures/attr_bench.exs",
      before_each_benchmark: fn benchmark ->
        assert Map.keys(benchmark) |> Enum.sort() ==
                 [:config, :description, :dir, :module, :title]

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

    assert BencheeDsl.run()
  end

  @tag :setup_all
  test "runs benchmark for setup_all_bench.exs" do
    BencheeDsl.BencheeMock
    |> expect(:run, fn jobs, config ->
      assert %{"do_it" => do_it} = jobs
      assert is_function(do_it, 0)

      assert Keyword.equal?(config,
               formatters: [Benchee.Formatters.Console],
               time: 1
             )

      if @benchee_run, do: assert(Benchee.run(jobs, config))
    end)

    assert BencheeDsl.config(file: "test/fixtures/setup_all_bench.exs")

    capture_log(fn ->
      assert BencheeDsl.run()
      Logger.flush()
    end) =~ "Hello.*Good.bye"
  end

  @tag :formatter
  test "runs benchmark for formatter_bench.exs" do
    BencheeDsl.BencheeMock
    |> expect(:run, fn jobs, config ->
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

    assert BencheeDsl.config(file: "test/fixtures/formatter_bench.exs")
    assert BencheeDsl.run()
  end

  @tag :before_each_benchmark
  test "runs function before_each_benchmark" do
    BencheeDsl.BencheeMock
    |> expect(:run, 2, fn jobs, config ->
      assert %{"do_it" => do_it} = jobs
      assert is_function(do_it, 0)

      if @benchee_run, do: assert(Benchee.run(jobs, config))
    end)

    assert BencheeDsl.config(
             path: "test/fixtures/math",
             before_each_benchmark: fn benchmark ->
               assert Enum.member?([Math.AddBench, Math.SubBench], benchmark.module)

               benchmark
             end
           )

    assert BencheeDsl.run()
  end

  @tag :all
  test "runs all benchmarks" do
    BencheeDsl.BencheeMock
    |> expect(:run, 10, fn jobs, config ->
      assert is_map(jobs)
      assert Keyword.keyword?(config)
    end)

    assert BencheeDsl.config(path: "test/fixtures")
    assert BencheeDsl.run()
  end
end
