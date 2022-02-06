defmodule Blockchain.Block do
  @moduledoc """
  Implements a blockchain block, which is a building block of the blockchain.
  Blocks are limited to containing transactions.
  """

  alias Blockchain.Transaction

  @enforce_keys [:current_hash, :previous_hash, :data, :timestamp, :nonce]
  defstruct @enforce_keys

  @typedoc """
  Represents a block
  """
  @type t :: %__MODULE__{
          current_hash: String.t(),
          previous_hash: String.t(),
          data: Transaction.t(),
          timestamp: DateTime.t(),
          nonce: integer()
        }

  @doc """
  Calculates a block's hash using the SHA hashing algorithm
  """
  @spec calculate_block_hash(String.t(), DateTime.t(), Transaction.t(), integer()) :: String.t()
  def calculate_block_hash(previous_hash, timestamp, transaction, nonce) do
    # Append all data as a list binaries or strings and then hash the list
    ExCrypto.Hash.sha256!([
      previous_hash,
      DateTime.to_string(timestamp),
      :erlang.term_to_binary(transaction),
      Integer.to_string(nonce)
    ])
  end

  @doc """
  Calculates a block's hash using the SHA hashing algorithm
  """
  @spec calculate_block_hash(__MODULE__.t()) :: String.t()
  def calculate_block_hash(block) do
    calculate_block_hash(block.previous_hash, block.timestamp, block.data, block.nonce)
  end

  @doc """
  Determines if a block is valid or not by re-calculating the block's hash and comparing it
  to the block's current hash
  """
  @spec valid_block?(__MODULE__.t()) :: boolean()
  def valid_block?(block) do
    block.current_hash ==
      calculate_block_hash(block.previous_hash, block.timestamp, block.data, block.nonce)
  end

  # Helper function to set the number of bytes a target will have
  @spec difficulty :: integer()
  defp difficulty, do: 2

  # A target for comparing hashes of blocks
  @spec target :: String.t()
  defp target, do: String.duplicate(<<32>>, difficulty())

  @doc """
  Determines if a block has been mined according to if the given hash matches
  the target
  """
  @spec mined_block?(String.t()) :: boolean()
  def mined_block?(block_hash) do
    binary_part(block_hash, 1, difficulty()) == binary_part(target(), 0, difficulty())
  end

  @doc """
  Implements the Hashcash procedure
  """
  @spec make_and_mine_block(String.t(), DateTime.t(), Transaction.t(), integer()) ::
          __MODULE__.t()
  def make_and_mine_block(previous_hash, timestamp, transaction, nonce) do
    current_hash = calculate_block_hash(previous_hash, timestamp, transaction, nonce)

    if mined_block?(current_hash) do
      %__MODULE__{
        current_hash: current_hash,
        previous_hash: previous_hash,
        data: transaction,
        timestamp: timestamp,
        nonce: nonce
      }
    else
      make_and_mine_block(previous_hash, timestamp, transaction, nonce + 1)
    end
  end

  @doc """
  Implements the Hashcash procedure
  """
  @spec make_and_mine_block(__MODULE__.t()) :: __MODULE__.t()
  def make_and_mine_block(block) do
    make_and_mine_block(block.previous_hash, block.timestamp, block.data, block.nonce)
  end

  @doc """
  Mines a block at the current time
  """
  @spec mine_block(Transaction.t(), String.t()) :: __MODULE__.t()
  def mine_block(transaction, previous_hash) do
    make_and_mine_block(previous_hash, DateTime.utc_now(), transaction, 1)
  end
end
