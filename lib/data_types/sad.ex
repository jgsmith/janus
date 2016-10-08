defmodule Mensendi.DataTypes.SAD do
  # Address
  use Mensendi.DSL.DataType

  component :street_or_mailing_address, :ST
  component :street_name, :ST
  component :dwelling_number, :ST
end
