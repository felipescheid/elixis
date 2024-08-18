defmodule Elixis.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(Elixis.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert Elixis.Registry.lookup(registry, "shopping") == :error

    Elixis.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Elixis.Registry.lookup(registry, "shopping")

    Elixis.Bucket.put(bucket, "eggs", 3)
    assert Elixis.Bucket.get(bucket, "eggs") == 3
  end

  test "removes bucket on exit", %{registry: registry} do
    Elixis.Registry.create(registry, "shopping")
    {:ok, bucket} = Elixis.Registry.lookup(registry, "shopping")

    Agent.stop(bucket)
    assert Elixis.Registry.lookup(registry, "shopping") == :error
  end
end
