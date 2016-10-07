defmodule XCNDataType do
  # Coded with exceptions
  use DataTypeDSL

  component :id_number, :ST
  component :family_name, :FN
  component :given_name, :ST
  component :additional_given_names, :ST
  component :suffix, :IS
  component :prefix, :IS
  component :assigning_authority, :HD
  component :name_type_code, :ID
  component :identifier_check_digit, :ST
  component :check_digit_scheme, :ID
  component :identifier_type_code, :ID
  component :assigning_facility, :HD
  component :name_representation_code, :ID
  component :name_context, :CE
  component :name_validity_range, :DR
  component :name_assembly_order, :ID
  component :effective_date, :TS
  component :expiration_date, :TS
  component :professional_suffix, :ST
  component :assigning_jurisdiction, :CWE
  component :assigning_agency, :CWE
end
