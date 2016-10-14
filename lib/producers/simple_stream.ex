defmodule Mensendi.Producers.SimpleStream do
  @moduledoc """
  Provides a simple producer that mimics the data from a socket. Useful for testing.
  """

  alias Experimental.GenStage

  use GenStage

  @doc false
  def init(_) do
    {:producer, {<< >>, 0}}
  end

  @spec inject(PID, binary) :: :ok
  def inject(pid, data) do
    GenStage.call(pid, {:inject, data})
  end

  @doc false
  def handle_demand(demand, {buffer, prior_demand}) when demand + prior_demand > 0 do
    total_demand = demand + prior_demand
    case buffer do
      << to_return :: bytes-size(total_demand), rest :: binary >> ->
        {:noreply, :binary.bin_to_list(to_return), {rest, 0}}
      _ ->
        {:noreply, :binary.bin_to_list(buffer), {<< >>, total_demand - byte_size(buffer)}}
    end
  end

  @doc false
  def handle_demand(0, {buffer, 0}) do
    {:noreply, [], {buffer, 0}}
  end

  @doc false
  def handle_call({:inject, data}, _from, {buffer, demand}) do
    with {:noreply, events, state} <- handle_demand(0, {buffer <> data, demand}) do
      {:reply, :ok, events, state}
    end
  end
end
