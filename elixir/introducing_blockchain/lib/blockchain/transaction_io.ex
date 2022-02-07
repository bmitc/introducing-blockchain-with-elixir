defmodule Blockchain.TransactionIO do
  @moduledoc """
  Implementation of blockchain transaction input/output (IO)
  """

  alias Blockchain.Hash

  @enforce_keys [:transaction_hash, :value, :owner, :timestamp]
  defstruct @enforce_keys

  @typedoc """
  Represents transaction IO
  """
  @type t :: %__MODULE__{
          transaction_hash: Hash.t(),
          value: integer(),
          owner: String.t(),
          timestamp: DateTime.t()
        }

  @doc """
  Create a new transaction IO
  """
  @spec new(integer(), String.t()) :: __MODULE__.t()
  def new(value, owner) do
    timestamp = DateTime.utc_now()

    %__MODULE__{
      transaction_hash: calculate_transaction_io_hash(value, owner, timestamp),
      value: value,
      owner: owner,
      timestamp: timestamp
    }
  end

  @doc """
  Calculates a transaction IO hash using the SHA hashing algorithm
  """
  @spec calculate_transaction_io_hash(integer(), String.t(), DateTime.t()) :: Hash.t()
  def calculate_transaction_io_hash(value, owner, timestamp) do
    # Append all data as a list of binaries or strings and then hash the list
    ExCrypto.Hash.sha256!([
      Integer.to_string(value),
      owner,
      DateTime.to_string(timestamp)
    ])
    |> Hash.new()
  end

  @doc """
  Calculates a transaction IO hash using the SHA hashing algorithm
  """
  @spec calculate_transaction_io_hash(__MODULE__.t()) :: Hash.t()
  def calculate_transaction_io_hash(transaction_io) do
    calculate_transaction_io_hash(
      transaction_io.value,
      transaction_io.owner,
      transaction_io.timestamp
    )
  end

  @doc """
  Determines if a transaction IO is valid or not by re-calculating the transction IO's
  hash and comparing it to the transaction IO's hash
  """
  @spec valid_transaction_io?(__MODULE__.t()) :: boolean()
  def valid_transaction_io?(transaction_io) do
    transaction_io.transaction_hash == calculate_transaction_io_hash(transaction_io)
  end
end
