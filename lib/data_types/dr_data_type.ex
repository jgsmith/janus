defmodule DRDataType do
  use DataTypeDSL

  component :start_date_time, :TS
  component :end_date_time, :TS
end
