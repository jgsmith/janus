defmodule Mensendi.DataTypes.AUI do
  # Authorization Information
  use Mensendi.DSL.DataType

  component :authorization_number, :ST
  component :date, :DT
  component :source, :ST
end
