BencheeDsl.before_each_benchmark(fn benchmark ->
  IO.inspect(benchmark, label: :before)
  benchmark
end)

BencheeDsl.run(
  time: 10,
  memory_time: 2
)
