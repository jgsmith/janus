defmodule Mensendi.DataTypes.AD do
  # Address
  use Mensendi.DSL.DataType

  component :street_address, :ST
  component :other_designation, :ST
  component :city, :ST
  component :state_or_provence, :ST
  component :zip_or_postal_code, :ST
  component :country, :ID
  component :address_type, :ID
  component :other_geographic_designation, :ST
end
