defmodule Mensendi.DataTypes.VID do
  use Mensendi.DSL.DataType

  component :version_id, :ID
  component :internationalization_code, :CE
  component :international_version_id, :CE
end
