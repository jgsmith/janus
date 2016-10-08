defmodule Mensendi.DataTypes.HD do
  use Mensendi.DSL.DataType

  component :namespace_id, :IS
  component :universal_id, :ST
  component :universal_id_type, :ID
end
