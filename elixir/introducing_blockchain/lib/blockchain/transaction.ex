defmodule Blockchain.Transaction do
  @moduledoc """
  Implements a blockchain transaction
  """

  @enforce_keys [:signature, :from, :to, :value]
  defstruct @enforce_keys

  @typedoc """
  Represents a transaction
  """
  @type t :: %__MODULE__{
          signature: String.t(),
          from: String.t(),
          to: String.t(),
          value: String.t()
        }

  @doc """
  Creates a new transaction
  """
  @spec new() :: __MODULE__.t()
  def new do
    %__MODULE__{
      signature: "",
      from: "",
      to: "",
      value: ""
    }
  end

  @doc """
  Creates a new transaction
  """
  @spec new(String.t(), String.t(), String.t(), String.t()) :: __MODULE__.t()
  def new(signature, from, to, value) do
    %__MODULE__{
      signature: signature,
      from: from,
      to: to,
      value: value
    }
  end
end
