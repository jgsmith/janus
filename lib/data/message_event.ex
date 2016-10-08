defmodule MessageEvent do
  @type t :: %MessageEvent{
    event: atom,
    description: String.t,
    message_structure: MessageGrammar.t,
    ack_structure: MessageGrammar.t
  }

  defstruct [event: nil, description: "", message_structure: nil, ack_structure: nil]
end