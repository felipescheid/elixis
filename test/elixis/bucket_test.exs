defmodule Elixis.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Elixis.Bucket.start_link([])
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
end
