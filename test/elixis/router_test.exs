defmodule Elixis.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route requests across nodes" do
    assert Elixis.Router.route("hello", Kernel, :node, []) == :"foo@Felipes-MacBook-Air"
    assert Elixis.Router.route("world", Kernel, :node, []) == :"bar@Felipes-MacBook-Air"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      Elixis.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
