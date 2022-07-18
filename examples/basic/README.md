# Basic Benchmark

This example contains `bench/exmaple_bench.exs` the example created by the mix
task `bench.gen`. This example can be started with:
```sh
mix bench bench/exmaple_bench.exs
```

The example `bench/example_delegate_bench.exs` shows a different version of
the Benchmark.
```sh
mix bench bench/example_delegate_bench.exs
```

With `mix bench` both benchmarks are executed.

The script `bench/example.exs` shows the benchmark without `BencheeDsl`. This
script is started with:
```sh
mix run bench/example.exs
```
