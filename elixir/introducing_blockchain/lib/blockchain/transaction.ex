defmodule Blockchain.Transaction do
  @moduledoc """
  Implements a blockchain transaction
  """

  alias Blockchain.Hash
  alias Blockchain.TransactionIO
  alias Blockchain.Wallet

  @enforce_keys [:signature, :from, :to, :value, :inputs, :outputs]
  defstruct @enforce_keys

  @typedoc """
  Represents a transaction
  """
  @type t :: %__MODULE__{
          signature: Hash.t(),
          from: Wallet.t(),
          to: Wallet.t(),
          value: number(),
          inputs: [TransactionIO.t()],
          outputs: [TransactionIO.t()]
        }

  @doc """
  Creates a new transaction
  """
  @spec new() :: __MODULE__.t()
  def new do
    %__MODULE__{
      signature: Hash.new(""),
      from: Wallet.new(),
      to: Wallet.new(),
      value: 0,
      inputs: [],
      outputs: []
    }
  end

  @doc """
  Creates a new transaction
  """
  @spec new(Wallet.t(), Wallet.t(), number(), [TransactionIO.t()]) :: __MODULE__.t()
  def new(%Wallet{} = from, %Wallet{} = to, value, inputs) when is_integer(value) do
    %__MODULE__{
      signature: Hash.new(""),
      from: from,
      to: to,
      value: value,
      inputs: inputs,
      outputs: []
    }
  end

  @doc """
  Updates the transcation's value but does not do any processing
  """
  @spec update_value(__MODULE__.t(), integer()) :: __MODULE__.t()
  def update_value(%__MODULE__{} = transaction, new_value) when is_integer(new_value) do
    %__MODULE__{transaction | value: new_value}
  end

  # @doc """
  # Creates a new transaction
  # """
  # @spec new(Hash.t(), String.t(), String.t(), String.t()) :: __MODULE__.t()
  # def new(signature, from, to, value) do
  #  %__MODULE__{
  #    signature: signature,
  #    from: from,
  #    to: to,
  #    value: value,
  #    inputs: [],
  #    outputs: []
  #  }
  # end

  @doc """
  The from and to wallets and the transaction value are hashed using SHA256, and
  then the hash is signed (i.e., encrypted) using the from wallet's private key
  and RSA
  """
  @spec sign_transaction(Wallet.t(), Wallet.t(), number()) :: Hash.t()
  def sign_transaction(%Wallet{} = from, %Wallet{} = to, value) do
    {:ok, signed_transaction} =
      ExPublicKey.sign(
        [
          :erlang.term_to_binary(from),
          :erlang.term_to_binary(to),
          to_string(value)
        ],
        from.private_key
      )

    Hash.new(signed_transaction)
  end

  @doc """
  The from and to wallets and the transaction value are hashed using SHA256, and
  then the hash is signed (i.e., encrypted) using the from wallet's private key
  and RSA
  """
  @spec sign_transaction(__MODULE__.t()) :: Hash.t()
  def sign_transaction(%__MODULE__{from: from, to: to, value: value} = _transaction) do
    sign_transaction(from, to, value)
  end

  @doc """
  Process a transaction
  """
  @spec process_transaction(__MODULE__.t()) :: __MODULE__.t()
  def process_transaction(
        %__MODULE__{
          from: from,
          to: to,
          value: value,
          inputs: inputs,
          outputs: outputs
        } = transaction
      ) do
    inputs_sum =
      inputs
      |> Enum.map(fn %TransactionIO{value: value} = _input -> value end)
      |> Enum.sum()

    leftover = inputs_sum - value

    new_outputs = [
      TransactionIO.new(value, to),
      TransactionIO.new(leftover, from)
    ]

    %__MODULE__{
      transaction
      | signature: sign_transaction(transaction),
        outputs: new_outputs ++ outputs
    }
  end

  @doc """
  Validates a transaction's signature
  """
  @spec valid_transaction_signature?(__MODULE__.t()) :: boolean()
  def valid_transaction_signature?(%__MODULE__{} = transaction) do
    public_key = transaction.from.public_key

    {:ok, verified?} =
      ExPublicKey.verify(
        [
          :erlang.term_to_binary(transaction.from),
          :erlang.term_to_binary(transaction.to),
          to_string(transaction.value)
        ],
        Hash.to_string(transaction.signature),
        public_key
      )

    verified?
  end

  @doc """
  Validates a transaction
  """
  @spec valid_transaction?(__MODULE__.t()) :: boolean()
  def valid_transaction?(%__MODULE__{inputs: inputs, outputs: outputs} = transaction) do
    sum_inputs = sum_transaction_io_list(inputs)
    sum_outputs = sum_transaction_io_list(outputs)

    Enum.all?([
      valid_transaction_signature?(transaction),
      Enum.all?(outputs, &TransactionIO.valid_transaction_io?/1),
      sum_inputs >= sum_outputs
    ])
  end

  # Helper function to sum all `TransactionIO` values
  @spec sum_transaction_io_list([TransactionIO.t()]) :: integer()
  defp sum_transaction_io_list(transaction_io_list) do
    transaction_io_list
    |> Enum.map(fn %TransactionIO{value: value} = _input -> value end)
    |> Enum.sum()
  end
end
