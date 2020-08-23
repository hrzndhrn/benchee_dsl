defmodule BencheDsl.ServerTest do
  use ExUnit.Case

  alias BencheeDsl.Server

  setup do
    {:ok, _server} = Server.start_link(name: __MODULE__)
    :ok
  end

  describe "register/4" do
    test "adds config" do
      Server.register(__MODULE__, :config, My.Test, time: 1)

      assert :sys.get_state(__MODULE__) == %{
               benchmarks: %{My.Test => %{config: [time: 1]}},
               config: []
             }
    end

    test "adds on_exit function" do
      fun = fn -> :ok end
      Server.register(__MODULE__, :on_exit, My.Test, fun)

      assert %{
               benchmarks: %{My.Test => %{on_exit: ^fun}},
               config: []
             } = :sys.get_state(__MODULE__)
    end

    test "adds on_exit function and config" do
      fun = fn -> :ok end
      Server.register(__MODULE__, :on_exit, My.Test, fun)
      Server.register(__MODULE__, :config, My.Test, time: 1)

      assert %{
               benchmarks: %{
                 My.Test => %{
                   on_exit: ^fun,
                   config: [time: 1]
                 }
               },
               config: []
             } = :sys.get_state(__MODULE__)
    end
  end
end
