defmodule TSDataType do
  use DataTypeDSL

  component :time, :DTM
  component :degree_of_precision, :ID
end
