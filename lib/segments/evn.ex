defmodule Mensendi.Segments.EVN do
  use Mensendi.DSL.Segment

  field :type_code, :ID
  field :recorded_date_time, :TS
  field :date_time_planned_event, :TS
  field :reason_code, :IS
  field :operator_id, :XCN
  field :event_occurred, :TS
  field :facility, :HD
end
