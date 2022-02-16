defmodule Blockchain.BlockTest do
  use ExUnit.Case, async: true

  alias Blockchain.Block
  alias Blockchain.Hash
  alias Blockchain.Transaction
  alias Blockchain.Wallet

  test "mined block is a valid block" do
    mined_block =
      Block.mine_block(Transaction.new(Wallet.new(), Wallet.new(), 0), Hash.new("some hash"))

    assert Block.mined?(mined_block.current_hash)
    assert Block.valid?(mined_block)
  end

  test "formatting a block as a string" do
    mined_block =
      Block.mine_block(Transaction.new(Wallet.new(), Wallet.new(), 0), Hash.new("some hash"))

    assert mined_block
           |> Block.format()
           |> String.valid?()
  end
end
