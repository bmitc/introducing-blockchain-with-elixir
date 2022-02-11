defmodule Blockchain.TransactionIOTest do
  use ExUnit.Case

  alias Blockchain.TransactionIO
  alias Blockchain.Wallet

  test "validate a transaction IO" do
    assert TransactionIO.valid_transaction_io?(TransactionIO.new(0, Wallet.new()))
  end
end
