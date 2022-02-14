defmodule Blockchain.BlockTest do
  use ExUnit.Case, async: true

  alias Blockchain.Block
  alias Blockchain.Hash
  alias Blockchain.Transaction

  test "mined block is a valid block" do
    mined_block = Block.mine_block(Transaction.new(), Hash.new("some hash"))

    assert Block.valid?(mined_block)
  end

  test "formatting a block" do
    mined_block = Block.mine_block(Transaction.new(), Hash.new("some hash"))

    assert mined_block
           |> Block.format()
           |> String.valid?()
  end
end
