defmodule Mensendi.Producers.TCPStream do
  @moduledoc """
  A producer transporting data from a TCP client socket into a GenStage sequence.
  """

  alias Experimental.GenStage

  use GenStage

  @spec write(PID, binary) :: :ok
  def write(pid, data) do
    GenStage.call(pid, {:write, data})
  end

  @doc false
  def init(socket) do
    {:producer, {<< >>, 0, socket}}
  end

  @doc false
  def handle_demand(demand, {buffer, prior_demand, socket}) when demand + prior_demand > 0 do
    total_demand = demand + prior_demand
    case buffer do
      << to_return :: bytes-size(total_demand), rest :: binary >> ->
        {:noreply, :binary.bin_to_list(to_return), {rest, 0, socket}}
      _ ->
        {:noreply, :binary.bin_to_list(buffer), {<< >>, total_demand - byte_size(buffer), socket}}
    end
  end

  @doc false
  def handle_call({:write, data}, _from, {_, _, socket} = state) do
    :gen_tcp.send(socket, data)
    {:reply, :ok, state}
  end

  @doc false
  def handle_info({:tcp, data}, {buffer, demand, socket}) do
    handle_demand(demand, {buffer <> data, 0, socket})
  end
end
