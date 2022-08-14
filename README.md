# BencheeDsl

[![Hex.pm versions](https://img.shields.io/hexpm/v/benchee_dsl.svg?style=flat-square)](https://hex.pm/packages/benchee_dsl)
[![GitHub: CI status](https://img.shields.io/github/workflow/status/hrzndhrn/benchee_dsl/CI?style=flat-square)](https://github.com/hrzndhrn/benchee_dsl/actions)
[![Coveralls: coverage](https://img.shields.io/coveralls/github/hrzndhrn/benchee_dsl?style=flat-square)](https://coveralls.io/github/hrzndhrn/benchee_dsl)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://github.com/hrzndhrn/benchee_dsl/blob/main/LICENSE.md)

`BencheeDsl` offers a DSL to write benchmarks for [Benchee](https://github.com/bencheeorg/benchee)
in an ExUnit style. For more informations to benchmarks and interpretation of
the results see the [Benchee documentation](https://hexdocs.pm/benchee/readme.html).

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fhrzndhrn%2Fbenchee_dsl%2Fblob%2Fmain%2Fbenchee_dsl.livemd)

## Installation

First, add `benchee` and `benchee_dsl` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:benchee, "~> 1.0.0", only: :dev},
    {:benchee_dsl, "~> 0.4", only: :dev}
  ]
end
```

Then, update your dependencies:
```shell
$ mix deps.get
```

## Usage
Generate the `bench` directory, the `bench/benchee_helper.exs`, and the example
`bench/example_bench.exs` with:

```
$ mix bench.gen
Create directory bench.
Write 'bench/benchee_helper.exs'.
Write 'bench/example_bench.exs'.
```

Start the benchmark with:

```
$ mix bench
...
Benchmarking flat_map with input Bigger...
Benchmarking flat_map with input Medium...
Benchmarking flat_map with input Small...
Benchmarking map_flatten with input Bigger...
Benchmarking map_flatten with input Medium...
Benchmarking map_flatten with input Small...
...
```

## Writing benchmarks

In the standard configuration the benchmarks are stored in the `bench`
directory. The benchmarks are saved in a file with the ending `_bench.exs`.

The example benchmark:

```elixir
defmodule ExampleBench do
  use BencheeDsl.Benchmark

  config time: 3, pre_check: true

  inputs %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }

  defp map_fun(i), do: [i, i * i]

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
```

### Adding a formatter

The next example uses the formatter [`benchee_markdown`](https://hex.pm/packages/benchee_markdown)

```elixir
defmodule ExampleBench do
  use BencheeDsl.Benchmark

  config time: 1

  formatter Benchee.Formatters.Markdown,
    file: Path.expand("example.md", __DIR__),
    description: """
    Bla bla bla ...
    """

  inputs %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }

  defp map_fun(i), do: [i, i * i]

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
```

### Inputs with do block

```elixir
defmodule ExampleBench do
  use BencheeDsl.Benchmark

  config time: 1

  inputs do
    data = data.json |> File.read!() |> Jason.decode()

    %{
      "Small" => Map.get(data, "small"),
      "Medium" => Map.get(data, "medium"),
      "Bigger" => Map.get(data, "bigger")
    }
  end

  defp map_fun(i), do: [i, i * i]

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
```

### Capture a job

Jobs can be captrured. In this case, the input must be a list with
the length of the function's arity. Note that the next example does not only
measueres `flat-map` and `map-flatten` but also `Enum.to_list`.


```elixir
defmodule Foo do
  def flat_map(a, b) do
    a |> data(b) |> Enum.flat_map(&map_fun/1)
  end

  def map_flatten(a, b) do
    a |> data(b) |> Enum.map(&map_fun/1) |> List.flatten()
  end

  defp data(a, b), do: Enum.to_list(a..b)

  defp map_fun(i), do: [i, i * i]
end

defmodule CaptureBench do
  use BencheeDsl.Benchmark

  inputs %{
    "small" => [1, 100],
    "medium" => [1, 10_000],
    "bigger" => [1, 100_000]
  }

  job &Foo.map_flatten/2

  job &Foo.flat_map/2
end
```

### Hooks

`BencheeDsl` accepts the tags
  * `@before_scenario`
  * `@before_each`
  * `@after_each`
  * `@after_each`
for a `job`. Each of this functions are accepting a function
with an arity of zero or one.

Global hooks are defined with the macros:
  * `BencheeDsl.Benchmark.before_scenario/2`
  * `BencheeDsl.Benchmark.before_each/2`
  * `BencheeDsl.Benchmark.after_each/2`
  * `BencheeDsl.Benchmark.after_scenario/2`

See the Benchee documentation for [hooks](https://github.com/bencheeorg/benchee#hooks-setup-teardown-etc)
for more informations.

The following example can be found at `example/sets`. The original benchmark
can be found at [josevalim/set_bench](https://github.com/josevalim/sets_bench).

```elixir
defmodule AddBench do
  use BencheeDsl.Benchmark

  inputs do
    small = 1..10
    medium = 1..1_000
    large = 1..100_000

    small_int_list = Enum.to_list(small)
    medium_int_list = Enum.to_list(medium)
    large_int_list = Enum.to_list(large)

    small_bin_list = Enum.map(small, fn _ -> :crypto.strong_rand_bytes(10) end)
    medium_bin_list = Enum.map(medium, fn _ -> :crypto.strong_rand_bytes(10) end)
    large_bin_list = Enum.map(large, fn _ -> :crypto.strong_rand_bytes(10) end)

    %{
      "small eq int" => [15, small_int_list],
      "medium eq int" => [1500, medium_int_list],
      "large eq int" => [150_000, large_int_list],
      "small eq bin" => [:crypto.strong_rand_bytes(10), small_bin_list],
      "medium eq bin" => [:crypto.strong_rand_bytes(10), medium_bin_list],
      "large eq bin" => [:crypto.strong_rand_bytes(10), large_bin_list]
    }
  end

  @before_scenario fn [arg1, arg2] -> [arg1, :gb_sets.from_list(arg2)] end
  job &:gb_sets.add_element/2

  @tag :skip
  @before_scenario fn [arg1, arg2] -> [arg1, :sets.from_list(arg2)] end
  job &:sets.add_element/2

  @before_scenario fn [arg1, arg2] -> [arg1, :ordsets.from_list(arg2)] end
  job &:ordsets.add_element/2
end
```

### Setup and exit

```elixir
defmodule ExampleBench do
  use BencheeDsl.Benchmark

  require Logger

  setup do
    Logger.info("Starting benchmark")

    on_exit fn ->
      Logger.info("Ready.")
    end
  end

  config time: 1

  inputs %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }

  defp map_fun(i) [i, i * i]

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end
end
```
