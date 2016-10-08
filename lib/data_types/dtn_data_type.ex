defmodule DTNDataType do
  # Day type and number
  use Mensendi.DSL.DataType

  component :day_type, :IS
  component :number_of_days, :NM
end
