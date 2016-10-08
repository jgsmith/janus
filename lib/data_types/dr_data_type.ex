defmodule DRDataType do
  use Mensendi.DSL.DataType

  component :start_date_time, :TS
  component :end_date_time, :TS
end
