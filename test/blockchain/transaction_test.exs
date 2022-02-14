defmodule Blockchain.TransactionTest do
  use ExUnit.Case, async: true

  alias Blockchain.Transaction

  test "validate a transaction's signature" do
    assert Transaction.new()
           |> Transaction.process()
           |> Transaction.valid_signature?()
  end

  test "validate transaction" do
    assert Transaction.new()
           |> Transaction.process()
           |> Transaction.valid?()
  end

  test "validate several transactions" do
    assert Transaction.new()
           |> Transaction.process()
           |> Transaction.update_value(1)
           |> Transaction.process()
           |> Transaction.update_value(2)
           |> Transaction.process()
           |> Transaction.valid?()
  end

  test "validate many transactions" do
    Enum.reduce(1..50, Transaction.new(), fn value, transaction ->
      new_transaction =
        transaction
        |> Transaction.update_value(value)
        |> Transaction.process()

      assert Transaction.valid?(new_transaction)
      new_transaction
    end)
  end
end
