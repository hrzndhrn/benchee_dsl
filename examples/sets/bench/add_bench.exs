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

  @setup fn [arg1, arg2] -> [arg1, :gb_sets.from_list(arg2)] end
  job &:gb_sets.add_element/2

  @tag :skip
  @setup fn [arg1, arg2] -> [arg1, :sets.from_list(arg2)] end
  job &:sets.add_element/2

  @setup fn [arg1, arg2] -> [arg1, :ordsets.from_list(arg2)] end
  job &:ordsets.add_element/2
end
