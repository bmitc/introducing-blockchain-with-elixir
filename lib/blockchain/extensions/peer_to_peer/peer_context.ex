defmodule Blockchain.Extensions.PeerToPeer.PeerContext do
  @moduledoc """
  Peer context
  """

  use GenServer

  alias Blockchain.Extensions.PeerToPeer.PeerInfoIO

  @enforce_keys [:name, :valid_peers, :connected_peers, :blockchain]
  defstruct [:port | @enforce_keys]

  @type t :: %{
          name: String.t(),
          port: pid(),
          valid_peers: MapSet.t(PeerInfoIO.t()),
          connected_peers: [PeerInfoIO.t()],
          blockchain: Blockchain.t()
        }

  @impl GenServer
  def init(%__MODULE__{} = peer_context) do
    {:ok, %__MODULE__{peer_context | port: self()}}
  end

  @impl GenServer
  def handle_call(:get_valid_peers, _from, %__MODULE__{} = peer_context) do
    {:reply, {:valid_peers, peer_context.valid_peers}, peer_context}
  end

  def handle_call(:get_latest_blockchain, _from, %__MODULE__{} = peer_context) do
    {:reply, {:valid_peers, peer_context.blockchain}, peer_context}
  end

  @impl GenServer
  def handle_cast(:latest_blockchain, %__MODULE__{} = peer_context) do
    {:noreply, peer_context}
  end

  def handle_cast({:valid_peers, new_valid_peers}, %__MODULE__{} = peer_context) do
    {:noreply, maybe_update_valid_peers(peer_context, new_valid_peers)}
  end

  def handle_cast(:exit, %__MODULE__{} = _peer_context) do
    {:stop, :peer_exit_requested}
  end

  @spec maybe_update_blockchain(__MODULE__.t(), Blockchain.t()) :: __MODULE__.t()
  defp maybe_update_blockchain(
         %__MODULE__{blockchain: current_blockchain} = peer_context,
         new_blockchain
       ) do
    if Blockchain.valid?(new_blockchain) and
         Blockchain.get_effort(new_blockchain) > Blockchain.get_effort(current_blockchain) do
      %__MODULE__{peer_context | blockchain: new_blockchain}
    else
      peer_context
    end
  end

  @spec maybe_update_valid_peers(
          %__MODULE__{:valid_peers => MapSet.t(PeerInfoIO.t())},
          MapSet.t(PeerInfoIO.t())
        ) :: %__MODULE__{:valid_peers => MapSet.t(PeerInfoIO.t())}
  defp maybe_update_valid_peers(
         %__MODULE__{} = peer_context,
         new_valid_peers
       ) do
    %__MODULE__{
      peer_context
      | valid_peers: MapSet.union(peer_context.valid_peers, new_valid_peers)
    }
  end

  defp get_potential_peers(
         %__MODULE__{valid_peers: valid_peers, connected_peers: connected_peers} = _peer_context
       ) do
    MapSet.difference(valid_peers, MapSet.new(connected_peers))
  end
end
