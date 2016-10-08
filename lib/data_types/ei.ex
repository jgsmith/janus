defmodule Mensendi.DataTypes.EI do
  use Mensendi.DSL.DataType

  component :identifier, :ST
  component :namespace_id, :IS
  component :universal_id, :ST
  component :universal_id_type, :ID
end
