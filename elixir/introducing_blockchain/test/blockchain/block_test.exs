defmodule Blockchain.BlockTest do
  use ExUnit.Case, async: true

  alias Blockchain.Block
  alias Blockchain.Hash
  alias Blockchain.Transaction

  test "mined block is a valid block" do
    mined_block = Block.mine_block(Transaction.new(), Hash.new("some hash"))

    assert Block.valid?(mined_block)
  end
end
