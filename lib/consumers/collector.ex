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
    {:consumer, []}
  end

  @doc """
  Retrieves any collected events.

  Retrieved events are cleared. Each call returns the events collected since the last call.
  """
  @spec retrieve(PID) :: List
  def retrieve(pid) do
    GenStage.call(pid, :retrieve)
  end

  @doc false
  def handle_events(events, from, list) do
    {:noreply, [], list ++ events}
  end

  @doc false
  def handle_call(:retrieve, _from, list) do
    {:reply, list, [], []}
  end
end
