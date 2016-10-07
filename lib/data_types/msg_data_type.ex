defmodule MSGDataType do
  use DataTypeDSL

  component :message_code, :ID
  component :trigger_event, :ID
  component :message_structure, :ID
end
