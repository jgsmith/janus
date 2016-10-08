defmodule EIDataType do
  use DataTypeDSL

  component :identifier, :ST
  component :namespace_id, :IS
  component :universal_id, :ST
  component :universal_id_type, :ID
end
