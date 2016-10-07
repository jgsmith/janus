defmodule OVRSegment do
  use SegmentDSL

  field :override_type, :CWE
  field :override_code, :CWE
  field :comment, :TX
  field :entered_by, :XCN
  field :authorized_by, :XCN
end
