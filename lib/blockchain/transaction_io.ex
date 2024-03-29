defmodule Blockchain.TransactionIO do
  @moduledoc """
  Implementation of blockchain transaction input/output (IO)
  """

  alias Blockchain.Hash
  alias Blockchain.Wallet

  @enforce_keys [:transaction_hash, :value, :owner, :timestamp]
  defstruct @enforce_keys

  @typedoc """
  Represents transaction IO
  """
  @type t :: %__MODULE__{
          transaction_hash: Hash.t(),
          value: number(),
          owner: Wallet.t(),
          timestamp: DateTime.t()
        }

  @doc """
  Create a new transaction IO
  """
  @spec new(number(), Wallet.t()) :: __MODULE__.t()
  def new(value, %Wallet{} = owner) do
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
  @spec calculate_transaction_io_hash(number(), Wallet.t(), DateTime.t()) :: Hash.t()
  def calculate_transaction_io_hash(value, %Wallet{} = owner, %DateTime{} = timestamp) do
    # Append all data as a list of binaries or strings and then hash the list
    ExCrypto.Hash.sha256!([
      to_string(value),
      :erlang.term_to_binary(owner),
      DateTime.to_string(timestamp)
    ])
    |> Hash.new()
  end

  @doc """
  Calculates a transaction IO hash using the SHA hashing algorithm
  """
  @spec calculate_transaction_io_hash(__MODULE__.t()) :: Hash.t()
  def calculate_transaction_io_hash(%__MODULE__{} = transaction_io) do
    calculate_transaction_io_hash(
      transaction_io.value,
      transaction_io.owner,
      transaction_io.timestamp
    )
  end

  @doc """
  Determines if a transaction IO is valid or not by re-calculating the transction IO's
  hash and comparing it to the transaction IO's existing hash
  """
  @spec valid?(__MODULE__.t()) :: boolean()
  def valid?(%__MODULE__{} = transaction_io) do
    transaction_io.transaction_hash == calculate_transaction_io_hash(transaction_io)
  end
end
