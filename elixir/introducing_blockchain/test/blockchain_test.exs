defmodule Blockchain.BlockchainTest do
  use ExUnit.Case

  alias Blockchain.Hash
  alias Blockchain.Transaction
  alias Blockchain.TransactionIO
  alias Blockchain.Wallet

  test "initializing a blockchain" do
    coin_base = Wallet.new()
    wallet_a = Wallet.new()
    genesis_transaction = Transaction.new(coin_base, wallet_a, 100, [])
    utxo = MapSet.new([TransactionIO.new(100, wallet_a)])

    assert Blockchain.init_blockchain(genesis_transaction, Hash.new("1337cafe"), utxo)
  end

  test "block reward calculation" do
    # https://www.bitcoinmining.com/what-is-the-bitcoin-block-reward/
    test_pairs = [
      {0, 50},
      {52_000, 50},
      {105_500, 50},
      {157_500, 50},
      {210_000, 25},
      {262_500, 25},
      {315_000, 25},
      {367_500, 25},
      {420_000, 12.5},
      {472_500, 12.5},
      {525_000, 12.5},
      {577_500, 12.5},
      {630_000, 6.25},
      {682_500, 6.25},
      {735_000, 6.25},
      {787_500, 6.25}
    ]

    for {number_of_blocks, expected_bitcoin_reward} <- test_pairs do
      assert expected_bitcoin_reward == Blockchain.calculate_reward_factor(number_of_blocks)
    end
  end

  test "adding transaction to blockchain" do
    coin_base = Wallet.new()
    wallet_a = Wallet.new()
    genesis_transaction = Transaction.new(coin_base, wallet_a, 100, [])
    utxo = MapSet.new([TransactionIO.new(100, wallet_a)])

    blockchain = Blockchain.init_blockchain(genesis_transaction, Hash.new("1337cafe"), utxo)

    assert Blockchain.add_transaction_to_blockchain(
             blockchain,
             Transaction.new(coin_base, wallet_a, 500, [])
           )
  end

  test "sending money on the blockchain" do
    coin_base = Wallet.new()
    wallet_a = Wallet.new()
    genesis_transaction = Transaction.new(coin_base, wallet_a, 100, [])
    utxo = MapSet.new([TransactionIO.new(100, wallet_a)])

    blockchain = Blockchain.init_blockchain(genesis_transaction, Hash.new("1337cafe"), utxo)

    assert Blockchain.send_money_blockchain(blockchain, wallet_a, Wallet.new(), 35)
           |> Blockchain.valid_blockchain?()
  end
end
