defmodule Mensendi.DataTypes.CCD do
  # Charge code and date
  use Mensendi.DSL.DataType

  component :invocation_event, :ID
  component :datetime, :TS
end
