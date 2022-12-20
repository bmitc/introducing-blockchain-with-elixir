defmodule Blockchain.Wallet do
  @moduledoc """
  Implementation of a blockchain wallet. Wallets are used in transactions
  and determine the source and destination of sending or receiving money.
  """

  @enforce_keys [:private_key, :public_key]
  defstruct @enforce_keys

  @typedoc """
  Represents a wallet
  """
  @type t :: %__MODULE__{
          private_key: ExPublicKey.RSAPrivateKey.t(),
          public_key: ExPublicKey.RSAPublicKey.t()
        }

  @doc """
  Creates a new wallet
  """
  @spec new() :: __MODULE__.t()
  def new() do
    {:ok, private_key} = ExPublicKey.generate_key(:rsa, 512, 65_537)
    {:ok, public_key} = ExPublicKey.public_key_from_private_key(private_key)

    %__MODULE__{
      private_key: private_key,
      public_key: public_key
    }
  end
end
