defmodule JobsUpdateBench do
  use BencheeDsl.Benchmark

  config time: 1

  jobs map do
    Map.put(map, "map", fn -> Enum.map(1..100, &Integer.to_string/1) end)
  end

  job add do
    1 + 1
  end
end
