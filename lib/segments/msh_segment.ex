defmodule MSHSegment do
  use SegmentDSL

  field :enc_chars, :ST
  field :sending_app, :HD
  field :sending_facility, :HD
  field :recv_app, :HD
  field :recv_facility, :HD
  field :time, :TS
  field :security, :ST
  field :message_type, :MSG
  field :message_control_id, :ST
  field :processing_id, :PT
  field :version_id, :VID
  field :seq, :NM
  field :continue_ptr, :ST
  field :accept_ack_type, :ID
  field :app_ack_type, :ID
  field :country_code, :ID
  field :charset, :ID
  field :principal_language_of_message, :CE
  field :alternate_character_set_handling_scheme, :ID
  field :message_profile_identifier, :EI
end
