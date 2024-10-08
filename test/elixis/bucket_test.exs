defmodule Elixis.BucketTest do
  use ExUnit.Case, async: true

  setup do
    bucket = start_supervised!(Elixis.Bucket)
    %{bucket: bucket}
  end

  test "store values by key", %{bucket: bucket} do
    assert Elixis.Bucket.get(bucket, "milk") == nil

    Elixis.Bucket.put(bucket, "milk", 3)
    assert Elixis.Bucket.get(bucket, "milk") == 3
  end

  test "delete values by key", %{bucket: bucket} do
    Elixis.Bucket.put(bucket, "eggs", 6)
    assert Elixis.Bucket.get(bucket, "eggs") == 6

    current_value = Elixis.Bucket.delete(bucket, "eggs")
    assert current_value == 6
    assert Elixis.Bucket.get(bucket, "eggs") == nil
  end

  test "are buckets temporary" do
    assert Supervisor.child_spec(Elixis.Bucket, []).restart == :temporary
  end
end
