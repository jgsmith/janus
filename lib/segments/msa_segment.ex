defmodule MSASegment do
  use SegmentDSL

  field :ack_code, :ID
  field :message_control_id, :ST
  field :text, :ST
  field :sequence_number, :NM
  field :delayed_ack
  field :error_condition, :CE
end
