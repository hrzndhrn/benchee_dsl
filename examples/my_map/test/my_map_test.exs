defmodule MyMapTest do
  use ExUnit.Case
  doctest MyMap

  test "greets the world" do
    assert MyMap.hello() == :world
  end
end
