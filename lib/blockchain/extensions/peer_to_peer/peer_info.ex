defmodule Blockchain.Extensions.PeerToPeer.PeerInfo do
  @moduledoc """
  Peer info
  """

  @enforce_keys [:id]
  defstruct @enforce_keys

  @type t :: %{
          id: pid()
        }
end
