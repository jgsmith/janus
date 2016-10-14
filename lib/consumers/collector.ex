defmodule Mensendi.Consumers.Collector do
  alias Experimental.GenStage
  use GenStage

  @moduledoc """
  A consumer for capping a producer/consumer flow and collecting the results.

  This module simply captures any events it receives and makes them available for retrieval
  via the `retrieve` function.
  """

  @doc false
  def init(_) do
    {:consumer, {[], :queue.new}}
  end

  @doc """
  Retrieves any collected events.

  Retrieved events are cleared. Each call returns the events collected since the last call.
  """
  @spec retrieve(PID, non_neg_integer) :: List
  def retrieve(pid, count \\ 0) do
    GenStage.call(pid, {:retrieve, count})
  end

  @doc false
  def handle_events(events, from, {list, q}) do
    dispatch_events({list ++ events, q})
  end

  def dispatch_events({list, q}) do
    available = Enum.count(list)
    with {{waiting_from, wanted}, new_queue} when available >= wanted <- :queue.out(q) do
      GenStage.reply(waiting_from, Enum.take(list, wanted))
      {:noreply, [], {Enum.drop(list, wanted), new_queue}}
    else
      _ -> {:noreply, [], {list, q}}
    end
  end

  @doc false
  def handle_call({:retrieve, 0}, _from, {list, q}) do
    {:reply, list, [], {[], q}}
  end

  def handle_call({:retrieve, count}, from, {list, q}) do
    if Enum.count(list) >= count do
      {:reply, list, [], {[], q}}
    else
      {:noreply, [], {list, :queue.in({from, count}, q)}}
    end
  end
end
