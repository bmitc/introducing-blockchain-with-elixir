defmodule Blockchain.TransactionTest do
  use ExUnit.Case

  alias Blockchain.Transaction

  test "validate a transaction's signature" do
    assert Transaction.valid_transaction_signature?(
             Transaction.process_transaction(Transaction.new())
           )
  end

  test "validate transaction" do
    assert Transaction.new()
           |> Transaction.process_transaction()
           |> Transaction.valid_transaction?()
  end

  test "validate several transactions" do
    assert Transaction.new()
           |> Transaction.process_transaction()
           |> Transaction.update_value(1)
           |> Transaction.process_transaction()
           |> Transaction.update_value(2)
           |> Transaction.process_transaction()
           |> Transaction.valid_transaction?()
  end

  test "validate many transactions" do
    Enum.reduce(1..500, Transaction.new(), fn value, transaction ->
      new_transaction =
        transaction
        |> Transaction.update_value(value)
        |> Transaction.process_transaction()

      assert Transaction.valid_transaction?(new_transaction)
      new_transaction
    end)
  end
end
