defmodule DLNDataType do
  # Address
  use Mensendi.DSL.DataType

  component :license_number, :ST
  component :issuing_authority, :IS
  component :expiration_date, :DT
end
