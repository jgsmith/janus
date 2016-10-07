defmodule CEDataType do
  use DataTypeDSL

  component :identifier, :ST
  component :text, :ST
  component :name_of_coding_system, :ID
  component :alternate_identifier, :ST
  component :alternate_text, :ST
  component :name_of_alternate_coding_system, :ID
end
