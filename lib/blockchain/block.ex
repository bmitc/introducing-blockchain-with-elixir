defmodule Blockchain.Block do
  @moduledoc """
  Implements a blockchain block, which is a building block of the blockchain.
  Blocks are limited to containing transactions.
  """

  alias Blockchain.Hash
  alias Blockchain.Transaction

  @enforce_keys [:current_hash, :previous_hash, :data, :timestamp, :nonce]
  defstruct @enforce_keys

  @typedoc """
  Represents a block
  """
  @type t :: %__MODULE__{
          current_hash: Hash.t(),
          previous_hash: Hash.t(),
          data: Transaction.t(),
          timestamp: DateTime.t(),
          nonce: non_neg_integer()
        }

  @doc """
  Calculates a block's hash using the SHA hashing algorithm
  """
  @spec calculate_hash(Hash.t(), DateTime.t(), Transaction.t(), non_neg_integer()) :: Hash.t()
  def calculate_hash(
        previous_hash,
        %DateTime{} = timestamp,
        %Transaction{} = transaction,
        nonce
      ) do
    # Append all data as a list of binaries or strings and then hash the list
    ExCrypto.Hash.sha256!([
      Hash.to_binary(previous_hash),
      DateTime.to_string(timestamp),
      :erlang.term_to_binary(transaction),
      Integer.to_string(nonce)
    ])
    |> Hash.new()
  end

  @doc """
  Calculates a block's hash using the SHA hashing algorithm
  """
  @spec calculate_hash(__MODULE__.t()) :: Hash.t()
  def calculate_hash(%__MODULE__{} = block) do
    calculate_hash(block.previous_hash, block.timestamp, block.data, block.nonce)
  end

  @doc """
  Determines if a block is valid or not by re-calculating the block's hash and comparing it
  to the block's current hash
  """
  @spec valid?(__MODULE__.t()) :: boolean()
  def valid?(%__MODULE__{} = block) do
    block.current_hash ==
      calculate_hash(block.previous_hash, block.timestamp, block.data, block.nonce)
  end

  @doc """
  Determines if a block has been mined according to if the block's current
  hash matches the target
  """
  @spec mined?(Hash.t()) :: boolean()
  def mined?(block_hash) do
    Hash.part(block_hash, 0, difficulty()) == Hash.part(target(), 0, difficulty())
  end

  @doc """
  Implements the Hashcash procedure
  """
  @spec make_and_mine_block(Hash.t(), DateTime.t(), Transaction.t(), non_neg_integer()) ::
          __MODULE__.t()
  def make_and_mine_block(
        previous_hash,
        %DateTime{} = timestamp,
        %Transaction{} = transaction,
        nonce
      )
      when nonce >= 0 and is_integer(nonce) do
    current_hash =
      calculate_hash(
        previous_hash,
        timestamp,
        %Transaction{} = transaction,
        nonce
      )

    if mined?(current_hash) do
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
  def make_and_mine_block(%__MODULE__{} = block) do
    make_and_mine_block(block.previous_hash, block.timestamp, block.data, block.nonce)
  end

  @doc """
  Mines a block at the current time
  """
  @spec mine_block(Transaction.t(), Hash.t()) :: __MODULE__.t()
  def mine_block(%Transaction{} = transaction, previous_hash) do
    make_and_mine_block(previous_hash, DateTime.utc_now(), transaction, 1)
  end

  @doc """
  Formats a block as a string suitable for printing
  """
  @spec format(__MODULE__.t()) :: String.t()
  def format(
        %__MODULE__{
          current_hash: current_hash,
          previous_hash: previous_hash,
          data: transaction,
          timestamp: timestamp,
          nonce: nonce
        } = _block
      ) do
    """
    Block information
    =================
    Hash: #{Hash.to_encoded_string(current_hash)}
    Previous Hash: #{Hash.to_encoded_string(previous_hash)}
    Timestamp: #{DateTime.to_string(timestamp)}
    Nonce: #{to_string(nonce)}
    Data: #{Transaction.format(transaction)}

    """
  end

  # Helper function to set the number of bytes a target will have
  @spec difficulty :: non_neg_integer()
  defp difficulty(), do: 2

  # A target for comparing hashes of blocks
  @spec target :: Hash.t()
  defp target() do
    <<32>>
    |> String.duplicate(difficulty())
    |> Hash.new()
  end
end
