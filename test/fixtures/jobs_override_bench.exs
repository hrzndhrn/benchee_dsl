defmodule JobsOverrideBench do
  use BencheeDsl.Benchmark

  config time: 1

  jobs do
    %{"map" => fn -> Enum.map(1..100, &Integer.to_string/1) end}
  end
end
