defmodule DLNDataType do
  # Address
  use DataTypeDSL

  component :license_number, :ST
  component :issuing_authority, :IS
  component :expiration_date, :DT
end
