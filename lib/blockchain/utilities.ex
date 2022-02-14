defmodule Blockchain.Utilities do
  @moduledoc """
  Common procedures
  """

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
