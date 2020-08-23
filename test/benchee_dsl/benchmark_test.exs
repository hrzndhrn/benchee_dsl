defmodule BencheeDsl.BenchmarkTest do
  use ExUnit.Case

  alias BencheeDsl.Benchmark

  describe "new/1" do
    test "returns a benchmark struct" do
      assert Benchmark.new(module: My.Module, config: [time: 1]) ==
               %BencheeDsl.Benchmark{
                 config: [time: 1],
                 description: nil,
                 dir: nil,
                 module: My.Module,
                 title: nil
               }
    end
  end

  describe "update/3" do
    test "returns benchmark with updated title" do
      benchmark = Benchmark.new(module: My.Module, config: [time: 1])

      assert Benchmark.update(benchmark, :title, fn _ -> "go" end) ==
               %BencheeDsl.Benchmark{
                 config: [time: 1],
                 description: nil,
                 dir: nil,
                 module: My.Module,
                 title: "go"
               }
    end

    test "returns benchmark with updated time" do
      benchmark = Benchmark.new(module: My.Module, config: [time: 1])

      assert Benchmark.update(benchmark, [:config, :time], fn _ -> 11 end) ==
               %BencheeDsl.Benchmark{
                 config: [time: 11],
                 description: nil,
                 dir: nil,
                 module: My.Module,
                 title: nil
               }
    end
  end
end
