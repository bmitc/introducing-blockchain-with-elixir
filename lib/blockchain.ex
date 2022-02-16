defmodule Blockchain do
  @moduledoc """
  The blockchain
  """

  alias Blockchain.Block
  alias Blockchain.Hash
  alias Blockchain.Transaction
  alias Blockchain.TransactionIO
  alias Blockchain.Wallet

  @enforce_keys [:blocks, :utxo]
  defstruct @enforce_keys

  @typedoc """
  Represents a blockchain
  """
  @type t :: %__MODULE__{
          blocks: [Block.t()],
          utxo: MapSet.t(TransactionIO)
        }

  @doc """
  Initialize a blockchain given a genesis transaction and genesis hash
  """
  @spec initialize(Transaction.t(), Hash.t()) :: __MODULE__.t()
  def initialize(%Transaction{value: value, to: to} = transaction, seed_hash) do
    seed_block =
      transaction
      |> Transaction.process()
      |> Block.mine_block(seed_hash)

    %__MODULE__{
      blocks: [seed_block],
      utxo: MapSet.new([TransactionIO.new(value, to)])
    }
  end

  @doc """
  Calculates the rewards for the number of blocks
  """
  @spec mining_reward_factor([Block.t()]) :: number()
  def mining_reward_factor(blocks) do
    blocks
    |> Enum.count()
    |> calculate_reward_factor()
  end

  @doc """
  Helper function to calculate the amount of rewards for mining a given number of blocks
  """
  @spec calculate_reward_factor(non_neg_integer()) :: number()
  def calculate_reward_factor(number_of_blocks)
      when is_integer(number_of_blocks) and number_of_blocks >= 0 do
    50 / Integer.pow(2, Integer.floor_div(number_of_blocks, 210_000))
  end

  @doc """
  Add a transaction to the blockchain. This mines a new block, creates a new UTXO based on
  the processed transaction outputs, inputs, and the current UTXO on the blockchain. Then
  the newly mined block is added to the blockchain's list of blocks, and the rewards are
  calculated based on the current UTXO.
  """
  @spec add_transaction(__MODULE__.t(), Transaction.t()) :: __MODULE__.t()
  def add_transaction(
        %__MODULE__{blocks: blocks, utxo: utxo} = _blockchain,
        %Transaction{from: from, inputs: processed_inputs, outputs: processed_outputs} =
          transaction
      ) do
    hashed_blockchain =
      Block.mine_block(transaction, blocks |> List.first() |> Map.fetch!(:current_hash))

    utxo =
      MapSet.union(
        MapSet.new(processed_outputs),
        MapSet.difference(utxo, MapSet.new(processed_inputs))
      )

    new_blocks = [hashed_blockchain | blocks]
    utxo_rewarded = MapSet.put(utxo, TransactionIO.new(mining_reward_factor(new_blocks), from))

    %__MODULE__{
      blocks: new_blocks,
      utxo: utxo_rewarded
    }
  end

  @doc """
  Calculate the balance of a wallet, which is the sum of all unspent transactions for the
  wallet's owner on the blockchain
  """
  @spec balance_wallet_blockchain(__MODULE__.t(), Wallet.t()) :: number()
  def balance_wallet_blockchain(%__MODULE__{utxo: utxo} = _blockchain, %Wallet{} = wallet) do
    utxo
    |> Enum.filter(fn transaction_io -> wallet == transaction_io.owner end)
    |> Enum.map(fn transaction_io -> transaction_io.value end)
    |> Enum.sum()
  end

  @doc """
  Send money from one wallet to another on the blockchain by initiating a transaction and processing
  it. The transaction is added to the blockchain only if it is valid.
  """
  @spec send_money(__MODULE__.t(), Wallet.t(), Wallet.t(), number()) :: __MODULE__.t()
  def send_money(
        %__MODULE__{utxo: utxo} = blockchain,
        %Wallet{} = from,
        %Wallet{} = to,
        value
      ) do
    receiver_transaction_ios =
      Enum.filter(utxo, fn transaction_io -> from == transaction_io.owner end)

    transaction = Transaction.new(from, to, value, receiver_transaction_ios)

    processed_transaction = Transaction.process(transaction)

    # If the balance of the sending wallet is greater than or equal to the value being sent
    # and the processed transaction is valid, add the transaction to the blockchain.
    # Otherwise, return the blockchain unchanged.
    if balance_wallet_blockchain(blockchain, from) >= value and
         Transaction.valid?(processed_transaction) do
      add_transaction(blockchain, processed_transaction)
    else
      blockchain
    end
  end

  @doc """
  Validates a blockchain
  """
  @spec valid?(__MODULE__.t()) :: boolean()
  def valid?(%__MODULE__{blocks: blocks} = _blockchain) do
    all_previous_hashes_except_last =
      blocks |> Enum.map(fn block -> block.previous_hash end) |> Enum.drop(-1)

    all_current_hashes_except_first =
      blocks |> Enum.map(fn block -> block.current_hash end) |> Enum.drop(1)

    all_blocks_valid? = Enum.all?(blocks, &Block.valid?/1)

    all_transactions_valid? =
      Enum.all?(Enum.map(blocks, fn block -> block.data end), &Transaction.valid?/1)

    all_blocks_mined? =
      Enum.all?(Enum.map(blocks, fn block -> block.current_hash end), &Block.mined?/1)

    all_previous_hashes_except_last == all_current_hashes_except_first and
      all_blocks_valid? and
      all_transactions_valid? and
      all_blocks_mined?
  end
end
