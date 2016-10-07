defmodule BTSSegment do
  use SegmentDSL

  field :message_count, :ST
  field :comment, :ST
  field :totals, :NM
end
