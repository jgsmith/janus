defmodule VIDDataType do
  use DataTypeDSL

  component :version_id, :ID
  component :internationalization_code, :CE
  component :international_version_id, :CE
end
