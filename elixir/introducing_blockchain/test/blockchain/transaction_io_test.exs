defmodule Blockchain.TransactionIOTest do
  use ExUnit.Case

  alias Blockchain.TransactionIO

  test "validate a transaction IO" do
    assert TransactionIO.valid_transaction_io?(TransactionIO.new(0, "test"))
  end
end
