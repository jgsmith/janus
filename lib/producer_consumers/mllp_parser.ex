defmodule Mensendi.ProducerConsumers.MLLPParser do
  require Logger
  alias Mensendi.Data.MLLPBuffer
  alias Experimental.GenStage
  use GenStage

  # alias __MODULE__
  @moduledoc """
  Provides the unpacking of data from the TCP connection to HL7 messages.
  """

  ## GenStage Callbacks

  @doc false
  def init(buffer) do
    {:producer_consumer, %{demand: 0, buffer: %{buffer | buffer: << >>}}}
  end

  defp dispatch_messages(messages, %{buffer: buffer} = state) do
    with {:ok, message, remainder} <- MLLPBuffer.next_message(buffer) do
      dispatch_messages([message | messages], %{state | buffer: remainder})
    else
      _ -> {:noreply, Enum.reverse(messages), state}
    end
  end

  @doc false
  def handle_events(events, _from, state) do
    with {:reply, :ok, new_state} <- do_inject_data(events, state) do
      dispatch_messages([], new_state)
    else
      _ -> {:noreply, [], state}
    end
  end

  defp do_inject_data(message, state) when is_list(message) do
    :binary.list_to_bin(message)
    |> do_inject_data(state)
  end

  defp do_inject_data(message, %{buffer: buffer} = state) when is_binary(message) do
    {:reply, :ok, %{state | buffer: MLLPBuffer.add_data(buffer, message)}}
  end
end
