defmodule Mix.Tasks.Bench.Gen do
  use Mix.Task

  import Mix.Shell.IO, only: [info: 1]

  @default_path "bench"

  @benchee_helper """
  BencheeDsl.run()
  """

  @example_bench """
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
  """

  @shortdoc "Generates basic benchmark structure"
  def run(_) do
    case File.exists?(@default_path) do
      true ->
        info("Directory '#{@default_path}' already exists.")

      false ->
        info("Create directory #{@default_path}.")
        File.mkdir_p!(@default_path)

        path = Path.join(@default_path, "benchee_helper.exs")
        File.write!(path, @benchee_helper)
        info("Write '#{path}'.")

        path = Path.join(@default_path, "example_bench.exs")
        File.write!(path, @example_bench)
        info("Write '#{path}'.")
    end
  end
end
