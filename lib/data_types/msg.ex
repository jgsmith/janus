defmodule Mensendi.DataTypes.MSG do
  use Mensendi.DSL.DataType

  component :message_code, :ID
  component :trigger_event, :ID
  component :message_structure, :ID
end
