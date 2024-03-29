defmodule Blockchain.Hash do
  @moduledoc """
  Implementation of a hash. Hashes are Elixir strings, which are UTF-8 strings,
  encoded as UTF-16 strings.
  """

  # The primary reason for this hash type implementation is because Elixir treats
  # strings as UTF-8. This means that many hashes will often simply display as
  # binaries when printed out rather than a "readable" string. Thus, we treat hashes
  # as UTF-16 strings, so that their value can appear more compactly as a string.
  #
  # In addition, having a type for hashes makes many functions more clear.

  @enforce_keys [:value]
  defstruct @enforce_keys

  @typedoc """
  Represents a hash
  """
  @opaque t :: %__MODULE__{
            value: String.t()
          }

  @doc """
  Create a new hash from a normal Elixir string or binary data

  ### Examples
  iex> Hash.new("test")
  %Hash{value: "74657374"}
  """
  @spec new(String.t() | binary()) :: __MODULE__.t()
  def new(string) do
    %__MODULE__{value: Base.encode16(string, case: :lower)}
  end

  @doc """
  Converts a hash to the underlying Elixir string
  """
  @spec to_binary(__MODULE__.t()) :: binary()
  def to_binary(%__MODULE__{} = hash) do
    hash.value |> Base.decode16!(case: :lower)
  end

  @doc """
  Converts a hash to a UTF-16 encoded string
  """
  @spec to_encoded_string(__MODULE__.t()) :: String.t()
  def to_encoded_string(%__MODULE__{} = hash) do
    hash.value
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
  def part(%{value: value}, start, length)
      when is_integer(start) and start >= 0 and is_integer(length) do
    value
    |> Base.decode16!(case: :lower)
    |> binary_part(start, length)
    |> new()
  end
end
