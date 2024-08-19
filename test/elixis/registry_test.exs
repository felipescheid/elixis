defmodule Elixis.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({Elixis.Registry, name: context.test})
    %{registry: context.test}
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

    # Agent.stop/1 is synchronous, so by the time we make the lookup the bucket has already stopped.
    # However, there is a potential race condition here as the registry may not have finished processing
    # the :DOWN message that triggers the removal of the bucket from the ETS table
    # Since messages are processed in order, we can make a synchronous request to the server to guarantee
    # that the :DOWN message will have finished processing
    Agent.stop(bucket)
    _ = Elixis.Registry.create(registry, "bogus")
    assert Elixis.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Elixis.Registry.create(registry, "shopping")
    {:ok, bucket} = Elixis.Registry.lookup(registry, "shopping")

    # if a process terminates with a reason other than :normal, all linked processes receive an EXIT signal
    Agent.stop(bucket, :shutdown)
    _ = Elixis.Registry.create(registry, "bogus")
    assert Elixis.Registry.lookup(registry, "shopping") == :error
  end
end
