defmodule Mensendi.Data.MessageEvent do
  alias Mensendi.Data.MessageEvent
  alias Mensendi.Utils.MessageGrammar

  @type t :: %MessageEvent{
    event: String.t,
    type: atom,
    title: String.t,
    description: String.t,
    message_structure: MessageGrammar.t,
    ack_structure: MessageGrammar.t,
    ack_type: String.t
  }

  defstruct [
    event: nil,
    type: nil,
    description: "",
    title: "",
    message_structure: nil,
    ack_structure: nil,
    ack_type: nil
  ]
end
