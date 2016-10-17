defmodule Mensendi.ProducerConsumers.HL7CharsetConversion do
  require Logger
  alias Experimental.GenStage
  use GenStage

  # alias __MODULE__
  @moduledoc """
  Provides the conversion of HL7 messages to UTF-8.

  Conversion is complicated because HL7 messages can change their encoding part-way through a message.
  """

  ## GenStage Callbacks

  @doc false
  def init(default_charset) do
    {:producer_consumer, {default_charset}}
  end

  @doc false
  def handle_events(events, _from, {default_charset} = state) do
    # assuming the HL7 doesn't specify a charset, we use `default_charset`
    # otherwise, we use the one in the message
    # input is a byte-string
    # output is a UTF-8 string
    {
      :noreply,
      events |> Enum.map(&(Mensendi.Utils.HL7CharsetConversion.convert_to_utf8(&1, default_charset))),
      state
    }
  end
end
