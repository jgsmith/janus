defmodule ELDDataType do
  use DataTypeDSL

  component :segment_id, :ST
  component :segment_sequence, :NM
  component :field_position, :NM
  component :code_identifying_error, :CE
end