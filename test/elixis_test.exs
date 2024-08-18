defmodule ElixisTest do
  use ExUnit.Case
  doctest Elixis

  test "greets the world" do
    assert Elixis.hello() == :world
  end
end
