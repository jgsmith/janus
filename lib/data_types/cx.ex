defmodule Mensendi.DataTypes.CX do
  # Coded with exceptions
  use Mensendi.DSL.DataType

  component :id_number, :ST
  component :check_digit, :ST
  component :check_digit_scheme, :ID
  component :assigning_authority, :HD
  component :identifier_type_code, :ID
  component :assigning_facility, :HD
  component :effective_date, :DT
  component :expiration_date, :DT
  component :assigning_juridiction, :CWE
  component :assigning_agency_or_department, :CWE
end
