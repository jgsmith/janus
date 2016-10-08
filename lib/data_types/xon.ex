defmodule Mensendi.DataTypes.XON do
  # Coded with exceptions
  use Mensendi.DSL.DataType

  component :name, :ST
  component :name_type_code, :IS
  component :id_number, :NM
  component :check_digit, :NM
  component :check_digit_scheme, :ID
  component :assigning_authority, :HD
  component :identifier_type_code, :ID
  component :assigning_facility, :HD
  component :name_representation_code, :ID
  component :identifier, :ST
end
