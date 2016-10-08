defmodule ERLDataType do
  use Mensendi.DSL.DataType

  component :segment_id, :ST
  component :segment_sequence, :NM
  component :field_position, :NM
  component :component_number, :NM
  component :sub_component_number, :NM
end
