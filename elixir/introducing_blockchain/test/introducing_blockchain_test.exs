defmodule IntroducingBlockchainTest do
  use ExUnit.Case
  doctest IntroducingBlockchain

  test "greets the world" do
    assert IntroducingBlockchain.hello() == :world
  end
end
