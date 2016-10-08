defmodule NTESegment do
  use Mensendi.DSL.Segment

  field :set_id, :SI
  field :source_of_comment, :ID
  field :comment, :FT
  field :comment_type, :CE
end
