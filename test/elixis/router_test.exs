defmodule Elixis.RouterTest do
  use ExUnit.Case

  setup_all do
    current = Application.get_env(:elixis, :routing_table)

    Application.put_env(:elixis, :routing_table, [
      {?a..?m, :"foo@Felipes-MacBook-Air"},
      {?n..?z, :"bar@Felipes-MacBook-Air"},
    ])

    on_exit fn -> Application.put_env(:elixis, :routing_table, current) end
  end

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
