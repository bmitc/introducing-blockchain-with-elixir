defmodule Blockchain.Hash do
  @moduledoc """
  Implementation of a hash. Hashes are Elixir strings, which are UTF-8 strings,
  encoded as UTF-16 strings.
  """

  # The primary reason for this hash type implementation is because Elixir treats
  # strings as UTF-8. This means that many hashes will often simply display as
  # binaries when printed out rather than a "readable" string. Thus, we treat hashes
  # as UTF-16 strings, so that their value can appear as a string that can be easily
  # copied, if needed.

  @enforce_keys [:value]
  defstruct @enforce_keys

  @typedoc """
  Represents a hash
  """
  @opaque t :: %__MODULE__{
            value: String.t()
          }

  @doc """
  Create a new hash from a normal Elixir string

  ### Examples
  iex> Hash.new("test")
  %Hash{value: "74657374"}
  """
  @spec new(String.t()) :: __MODULE__.t()
  def new(string) do
    %__MODULE__{value: Base.encode16(string, case: :lower)}
  end

  @doc """
  Converts a hash to an Elixir string
  """
  @spec to_string(__MODULE__.t()) :: String.t()
  def to_string(hash) do
    hash.value |> Base.decode16!(case: :lower)
  end

  @doc """
  Extracts part of the hash's underlying binary representation starting at
  `start` (0-indexed) and of length `length`

  ### Examples
  iex> Hash.new("test")
  %Hash{value: "74657374"}

  iex> Hash.part(Hash.new("test"), 1, 2)
  %Hash{value: "6573"}

  iex> Hash.part(Hash.new("test"), 2, 2)
  Hash.new("st")
  """
  @spec part(__MODULE__.t(), non_neg_integer(), integer()) :: __MODULE__.t()
  def part(%{value: value}, start, length) do
    value
    |> Base.decode16!(case: :lower)
    |> binary_part(start, length)
    |> new()
  end
end
