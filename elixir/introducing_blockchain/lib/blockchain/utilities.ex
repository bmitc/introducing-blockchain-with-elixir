defmodule Blockchain.Utilities do
  @moduledoc """
  Common procedures
  """

  @doc """
  Returns true if the given predicate is true for all members of the given list,
  otherwise returns false

  ### Examples
    iex> Utilities.true_for_all?(fn x -> x > 3 end, [1, 2, 3])
    false

    iex> Utilities.true_for_all?(fn x -> x > 3 end, [4, 5, 6])
    true
  """
  @spec true_for_all?((any() -> boolean()), list()) :: any()
  def true_for_all?(predicate, list) do
    Enum.all?(list, predicate)
  end

  @doc """
  Writes any Elixir data to a file
  """
  @spec data_to_file(map(), String.t()) :: :ok
  def data_to_file(map, file) do
    File.write!(file, :erlang.term_to_binary(map))
  end

  @doc """
  Reads any Elixir data from a file
  """
  @spec file_to_data(String.t()) :: term()
  def file_to_data(file) do
    file
    |> File.read!()
    |> :erlang.binary_to_term()
  end
end
