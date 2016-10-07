defmodule SFTSegment do
  use SegmentDSL

  field :vendor_organization, :XON
  field :certified_version, :ST
  field :product_name, :ST
  field :binary_id, :ST
  field :product_information, :TX
  field :install_date, :TS
end
