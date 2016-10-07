defmodule CCDDataType do
  # Charge code and date
  use DataTypeDSL

  component :invocation_event, :ID
  component :datetime, :TS
end
