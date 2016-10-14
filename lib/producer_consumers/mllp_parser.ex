defmodule Mensendi.ProducerConsumers.MLLPParser do
  require Logger
  alias Mensendi.Data.MLLPBuffer
  alias Experimental.GenStage
  use GenStage

  # alias __MODULE__
  @moduledoc """
  Provides the unpacking of data from the TCP connection to HL7 messages.

  When starting an InboundMLLPTransport server, pass in the socket that is receiving the data.
  This is not the socket listening for connections.

  The socket must be created with the options `[:binary, active: :once]` and the owner set
  to the instance of this server that is given the socket.`
  """

  ## GenStage Callbacks

  @doc false
  def init(buffer) do
    {:producer_consumer, %{demand: 0, buffer: %{buffer | buffer: << >>}, producers: %{}}}
  end

  defp dispatch_messages(messages, %{buffer: buffer} = state) do
    with {:ok, message, remainder} <- MLLPBuffer.next_message(buffer) do
      dispatch_messages([message | messages], %{state | buffer: remainder})
    else
      _ -> {:noreply, Enum.reverse(messages), state}
    end
  end

  @doc false
  def handle_events(events, from, %{producers: producers} = state) do
    updated_state = state #%{state | producers: updated_producers}
    with {:reply, :ok, new_state} <- do_inject_data(events, updated_state) do
      dispatch_messages([], new_state)
    else
      foo ->
        IO.puts(inspect(foo))
        {:noreply, [], updated_state}
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
