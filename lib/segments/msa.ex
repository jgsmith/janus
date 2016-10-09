defmodule Mensendi.Segments.MSA do
  use Mensendi.DSL.Segment

  field :ack_code, :ID
  field :message_control_id, :ST
  field :text, :ST
  field :sequence_number, :NM
  field :delayed_ack, :ST
  field :error_condition, :CE
end
