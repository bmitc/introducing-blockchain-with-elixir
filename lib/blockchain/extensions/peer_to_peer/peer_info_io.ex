defmodule Blockchain.Extensions.PeerToPeer.PeerInfoIO do
  @moduledoc """
  Peer info IO
  """

  alias Blockchain.Extensions.PeerToPeer.PeerInfo

  @enforce_keys [:peer_info, :input_port, :output_port]
  defstruct @enforce_keys

  @type t :: %{
          peer_info: PeerInfo.t(),
          input_port: any(),
          output_port: any()
        }
end
