defmodule Blockchain.Extensions.SmartContractsTest do
  use ExUnit.Case, aync: true

  alias Blockchain.Extensions.SmartContracts
  alias Blockchain.Transaction
  alias Blockchain.Wallet

  setup do
    from_wallet = Wallet.new()
    to_wallet = Wallet.new()
    value = 456
    transaction = Transaction.new(from_wallet, to_wallet, value, [])

    {:ok, from_wallet: from_wallet, to_wallet: to_wallet, value: value, transaction: transaction}
  end

  test "number contract", %{transaction: transaction} do
    assert SmartContracts.eval(transaction, 123) == 123
  end

  test "string contract", %{transaction: transaction} do
    assert SmartContracts.eval(transaction, "Hi") == "Hi"
  end

  test "empty contract", %{transaction: transaction} do
    assert SmartContracts.eval(transaction, []) == true
    assert SmartContracts.eval(transaction, {}) == true
  end

  test "boolean contract", %{transaction: transaction} do
    assert SmartContracts.eval(transaction, true)
    refute SmartContracts.eval(transaction, false)
  end

  test "if-then-else contract", %{transaction: transaction} do
    assert SmartContracts.eval(transaction, {:if, true, "Hi", "Hey"}) == "Hi"
    assert SmartContracts.eval(transaction, {:if, false, "Hi", "Hey"}) == "Hey"
  end

  test "addition contract", %{transaction: transaction} do
    assert SmartContracts.eval(transaction, {:+, 1, 2}) == 3
  end

  test "transaction contracts", %{
    from_wallet: from_wallet,
    to_wallet: to_wallet,
    value: value,
    transaction: transaction
  } do
    assert SmartContracts.eval(transaction, :from) == from_wallet
    assert SmartContracts.eval(transaction, :to) == to_wallet
    assert SmartContracts.eval(transaction, :value) == value
  end

  test "composed contract", %{
    from_wallet: from_wallet,
    to_wallet: to_wallet,
    transaction: transaction
  } do
    assert SmartContracts.eval(transaction, {:if, {:==, {:+, 1, 2}, 3}, :from, :to}) ==
             from_wallet

    assert SmartContracts.eval(transaction, {:if, {:==, {:+, 1, 2}, 4}, :from, :to}) ==
             to_wallet
  end
end
