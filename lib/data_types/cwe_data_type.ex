defmodule CWEDataType do
  # Coded with exceptions
  use Mensendi.DSL.DataType

  component :identifier, :ST
  component :text, :ST
  component :name_of_coding_system, :ID
  component :alternate_identifier, :ST
  component :alternate_text, :ST
  component :name_of_alternate_coding_system, :ID
  component :coding_system_version_id, :ST
  component :alternate_coding_system_version_id, :ST
  component :original_text, :ST
end
