defmodule Mensendi.Servers.InboundListener do
  @moduledoc """
  Manages the inbound MLLP/HL7 data flow.
  """

  # we want to start a tree of processes
  # we pass in the module that handles individual connections
  alias Mensendi.Producers.TCPStream
  alias Experimental.GenStage

  def start_link(socket, _callback) do
    Task.start_link(fn -> loop_acceptor(%{connections: [], socket: socket}) end)
  end

  defp loop_acceptor(%{socket: socket} = state) do
    {:ok, client} = :gen_tcp.accept(socket)
    client |> serve(state) |> loop_acceptor
  end

  defp serve(socket, %{transport: _transport, connections: _connections} = _state) do
    {:ok, pid} = GenStage.start_link(TCPStream, socket)
    :ok = :gen_tcp.controlling_process(socket, pid)
  end
end
