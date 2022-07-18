# Changelog

## 0.2.0 - dev

### Breaking changes

+ Update `BencheeDsl.Benchmark.job`. The job macro no longer defines a function.
  The macro now generates an anonymous function that is managed by BencheeDsl.
+ Remove macros `BencheeDsl.Benchmark.jobs/0/1`.

## 0.1.5 - 2022/07/17

+ Add local hooks (`@before_scenario`, `@before_each`, `@after_scenario`, `@after_each`)
+ Overwrite benchmark config when running `BencheeDsl.Benchmark.run/1`.

## 0.1.4 2022/07/16

+ Add `recode` dependency.
+ Add `BencheeDsl.Benchmark.run/0/1` to run benchmarks in `iex` and `livebook`.

## 0.1.3 2021/07/04

+ Add `@before`.

## 0.1.2 2021/06/25

+ Add macro `jobs`.
+ Add delegate option to macro `job`

## 0.1.1 2020/10/21

+ Add file option to `mix bench`.

## 0.1.0 2020/08/23

+ The very first version.
