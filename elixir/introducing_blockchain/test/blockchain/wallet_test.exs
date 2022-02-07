defmodule Blockchain.WalletTest do
  use ExUnit.Case

  alias Blockchain.Wallet

  test "creating a new wallet" do
    assert wallet = Wallet.new()
    assert wallet.private_key
    assert wallet.public_key
  end
end
