defmodule DTNDataType do
  # Day type and number
  use DataTypeDSL

  component :day_type, :IS
  component :number_of_days, :NM
end
