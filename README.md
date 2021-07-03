# BencheeDsl
[![Hex.pm](https://img.shields.io/hexpm/v/benchee_dsl.svg)](https://hex.pm/packages/benchee_dsl)
[![CI](https://github.com/hrzndhrn/benchee_dsl/workflows/CI/badge.svg)](https://github.com/hrzndhrn/benchee_dsl/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`BencheeDsl` provides a DSL to write benchmarks for
[`Benchee`](https://github.com/bencheeorg/benchee).

For now, just an early alpha version.

## Installation

First, add `benchee` and `benchee_dsl` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:benchee, "~> 1.0.0", only: :dev},
    {:benchee_dsl, "~> 0.1.0", only: :dev}
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

  config time: 1

  inputs %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
```

### Adding a formatter

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

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
```

### inputs with do block

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

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
```

### job delgates
Jobs can be delegated to functions. In this case, the input must be a list with
the length of the function's arity.


```elixir
defmodule Foo do
  def flat_map(a, b) do
    a |> data(b) |> Enum.flat_map(&map_fun/1)
  end

  def map_flatten(a, b) do
    a |> data(b) |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def data(a, b), do: Enum.to_list(a..b)

  def map_fun(i), do: [i, i * i]
end

defmodule DelegateBench do
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

### @before
Jobs tagged with `@before` are getting a function to transform the input. The
following example can be found at `example/sets`.

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

  @before fn [arg1, arg2] -> [arg1, :gb_sets.from_list(arg2)] end
  job &:gb_sets.add_element/2

  @tag :skip
  @before fn [arg1, arg2] -> [arg1, :sets.from_list(arg2)] end
  job &:sets.add_element/2

  @before fn [arg1, arg2] -> [arg1, :ordsets.from_list(arg2)] end
  job &:ordsets.add_element/2
end
```

### setup, on_exit

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

  job flat_map(input) do
    Enum.flat_map(input, &map_fun/1)
  end

  job map_flatten(input) do
    input |> Enum.map(&map_fun/1) |> List.flatten()
  end

  def map_fun(i), do: [i, i * i]
end
```
