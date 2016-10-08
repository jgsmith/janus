defmodule MSHSegmentTest do
  use ExUnit.Case
  doctest MSHSegment

  test "gets the right data from the raw segment" do
    segment = Mensendi.Data.Segment.from_string(
      "MSH|^~\\&|CERNER||PriorityHealth||20160102||ORU^R01|Q479004375T431430612|P|2.3",
      %Mensendi.Data.Delimiters{}
    )
    |> MSHSegment.from_segment

    # Note that "enc_chars" will be escaped since the Field.to_string doesn't know this
    # is a special field that shouldn't escape the escape character
    # assert Field.to_string(segment.enc_chars) == "^~\\E\\&"
    assert List.first(segment.sending_app).namespace_id.value == "CERNER"
    assert List.first(segment.sending_facility).namespace_id.value == ""
    assert List.first(segment.recv_app).namespace_id.value == "PriorityHealth"
    assert List.first(segment.recv_facility).namespace_id.value == ""
    assert List.first(segment.message_type).message_code.value == "ORU"
    assert List.first(segment.message_type).trigger_event.value == "R01"
    assert List.first(segment.message_control_id).value == "Q479004375T431430612"
    assert List.first(segment.processing_id).processing_id.value == "P"
    assert List.first(segment.version_id).version_id.value == "2.3"
  end
end
