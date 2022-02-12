defmodule Blockchain.Types do
  @moduledoc """
  Blockchain related types
  """

  @typedoc """
  Represents a public key
  """
  @opaque public_key :: ExPublicKey.RSAPublicKey.t()

  @typedoc """
  Represents a private key
  """
  @opaque private_key :: ExPublicKey.RSAPrivateKey.t()
end
