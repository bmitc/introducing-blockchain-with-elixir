defmodule Blockchain.HashTest do
  use ExUnit.Case

  alias Blockchain.Hash

  doctest Hash

  test "hashes encode strings properly" do
    test_string = "hash test string for encoding"

    assert test_string ==
             test_string
             |> Hash.new()
             |> Map.fetch!(:value)
             |> Base.decode16!(case: :lower)
  end

  test "part gets subpart correctly" do
    assert Hash.part(Hash.new("asdfqwerty"), 1, 5) == Hash.new("sdfqw")
  end

  test "part reports out of range error when index is too large" do
    assert_raise ArgumentError, ~r/out of range/, fn -> Hash.part(Hash.new("zxcv"), 4, 1) end
  end

  test "part reports out of range error when length is too long" do
    assert_raise ArgumentError, ~r/out of range/, fn -> Hash.part(Hash.new("zxcv"), 0, 5) end
  end
end
