defmodule Mensendi.Segments.BTS do
  use Mensendi.DSL.Segment

  field :message_count, :ST
  field :comment, :ST
  field :totals, :NM
end
