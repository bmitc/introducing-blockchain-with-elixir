defmodule Blockchain.TransactionIOTest do
  use ExUnit.Case, async: true

  alias Blockchain.TransactionIO
  alias Blockchain.Wallet

  test "validate a transaction IO" do
    assert TransactionIO.valid?(TransactionIO.new(0, Wallet.new()))
  end
end
