defmodule BHSSegment do
  use Mensendi.DSL.Segment

  field :encoding_characters, :ST
  field :sending_application, :HD
  field :sending_facility, :HD
  field :receiving_application, :HD
  field :receiving_facility, :HD
  field :time, :TS
  field :security, :ST
  field :name, :ST
  field :comment, :ST
  field :control_id, :ST
  field :reference_control_id, :ST
end
