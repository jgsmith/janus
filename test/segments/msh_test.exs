defmodule Mensendi.Segments.MSHTest do
  use ExUnit.Case
  alias Mensendi.Data.Segment
  alias Mensendi.Segments.MSH
  doctest MSH

  test "gets the right data from the raw segment" do
    segment =
      "MSH|^~\\&|CERNER||PriorityHealth||20160102||ORU^R01|Q479004375T431430612|P|2.3"
      |> Segment.from_string
      |> MSH.from_segment

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
