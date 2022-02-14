defmodule Blockchain.UtilitiesTest do
  use ExUnit.Case, async: true

  alias Blockchain.Transaction
  alias Blockchain.Utilities
  alias Blockchain.Wallet

  doctest Utilities

  describe "writing and reading Elixir data" do
    # Intentionally scope the setup block so that it isn't ran during doctests
    setup do
      temporary_directory = System.tmp_dir!()
      temporary_file_path = Path.join(temporary_directory, "test.txt")

      on_exit(fn -> File.rm!(temporary_file_path) end)

      %{temporary_file_path: temporary_file_path}
    end

    test "writing and reading a Transaction", %{temporary_file_path: temporary_file_path} do
      assert_write_and_read(Transaction.new(), temporary_file_path)
    end

    test "writing and reading a Wallet", %{temporary_file_path: temporary_file_path} do
      assert_write_and_read(Wallet.new(), temporary_file_path)
    end

    test "writing and reading a list of structs", %{temporary_file_path: temporary_file_path} do
      assert_write_and_read([Transaction.new(), Wallet.new()], temporary_file_path)
    end
  end

  # Writes the data and then reads it, asserting if the data that was written
  # is what is read back
  @spec assert_write_and_read(any(), String.t()) :: term()
  defp assert_write_and_read(data, file_path) do
    Utilities.data_to_file(data, file_path)
    assert Utilities.file_to_data(file_path) == data
  end
end
