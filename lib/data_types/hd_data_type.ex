defmodule HDDataType do
  use DataTypeDSL

  component :namespace_id, :IS
  component :universal_id, :ST
  component :universal_id_type, :ID
end
