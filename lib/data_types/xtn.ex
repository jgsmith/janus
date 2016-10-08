defmodule Mensendi.DataTypes.XTN do
  # Extended telecommunication number
  use Mensendi.DSL.DataType

  component :telephone_number, :ST
  component :use_code, :ID
  component :equipment_type, :ID
  component :email_address, :ST
  component :country_code, :NM
  component :area_city_code, :NM
  component :local_number, :NM
  component :extension, :NM
  component :any_text, :ST
  component :extension_prefix, :ST
  component :speed_dial_code, :ST
  component :unformatted_telephone_number, :ST
end
