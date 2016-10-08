defmodule XADDataType do
  # Address
  use DataTypeDSL

  component :street_address, :SAD
  component :other_designation, :ST
  component :city, :ST
  component :state_or_provence, :ST
  component :zip_or_postal_code, :ST
  component :country, :ID
  component :address_type, :ID
  component :other_geographic_designation, :ST
  component :county_parish_code, :IS
  component :census_tract, :IS
  component :address_representation_code, :ID
  component :address_validity_range, :DR
  component :effective_date, :TS
  component :expiration_date, :TS
end
