defmodule TSDataType do
  use Mensendi.DSL.DataType

  component :time, :DTM
  component :degree_of_precision, :ID
end
