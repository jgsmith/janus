defmodule Mensendi.Segments.FTS do
  use Mensendi.DSL.Segment

  field :message_count, :ST
  field :comment, :ST
end
