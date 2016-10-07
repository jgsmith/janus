defmodule AUIDataType do
  # Authorization Information
  use DataTypeDSL

  component :authorization_number, :ST
  component :date, :DT
  component :source, :ST
end
