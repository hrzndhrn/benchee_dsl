# BencheeDsl

`BencheDsl` provides a DSL to write benchmarks for
[`Benchee`](https://github.com/bencheeorg/benchee).

For now, just an early alpha version.

## Installation

The package isn't released on [hex](https://hex.pm/). You can install the
package via GitHub.

```elixir
def deps do
  [
    {:benchee, "~> 1.0.0", only: :dev},
    {:benchee_dsl, git: "https://github.com/hrzndhrn/benchee_dsl", only: :dev}
  ]
end
```

## Usage
Generate the `bench` directory, the `benchee_helper.exs`, and the example
`example_bench.exs` with:

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
