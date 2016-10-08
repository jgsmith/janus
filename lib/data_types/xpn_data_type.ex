defmodule XPNDataType do
  use DataTypeDSL

  component :family_name, :FN
  component :given_name, :ST
  component :additional_given_names, :ST
  component :suffix, :ST
  component :prefix, :ST
  component :degree, :IS
  component :name_type_code, :ID
  component :name_representation_code, :ID
  component :name_context, :CE
  component :name_validity_range, :DR
  component :name_assembly_order, :ID
  component :effective_date, :TS
  component :expiration_date, :TS
  component :professional_suffix, :ST
end
