# BencheeDsl

`BencheDsl` provides a DSL to write benchmarks for
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
> mix bench.gen
Create directory bench.
Write 'bench/benchee_helper.exs'.
Write 'bench/example_bench.exs'.
```

Start the benchmark with:

```
> mix bench
...
Benchmarking flat_map with input Bigger...
Benchmarking flat_map with input Medium...
Benchmarking flat_map with input Small...
Benchmarking map_flatten with input Bigger...
Benchmarking map_flatten with input Medium...
Benchmarking map_flatten with input Small...
...
```

## Writing benchmakrs

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
