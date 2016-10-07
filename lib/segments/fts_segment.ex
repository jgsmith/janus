defmodule FTSSegment do
  use SegmentDSL

  field :message_count, :ST
  field :comment, :ST
end
