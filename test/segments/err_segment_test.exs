defmodule ERRSegmentTest do
  use ExUnit.Case
  doctest ERRSegment

  test "gets the right data from the raw segment" do
    segment = Mensendi.Data.Segment.from_string(
      "ERR||PID^5|101^required field missing^HL70357|E",
      %Mensendi.Data.Delimiters{}
    )
    |> ERRSegment.from_segment

    assert List.first(segment.code_and_location) == %ELDDataType{}
    assert List.first(segment.location) == %ERLDataType{
      segment_id: %STDataType{value: "PID"},
      segment_sequence: %NMDataType{value: 5.0}
    }
    assert List.first(segment.hl7_error_code) == %CWEDataType{
      identifier: STDataType.from_string("101"),
      text: STDataType.from_string("required field missing"),
      name_of_coding_system: IDDataType.from_string("HL70357")
    }
    assert segment.severity == [IDDataType.from_string("E")]
  end
end
