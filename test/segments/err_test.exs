defmodule Mensendi.Segments.ERRTest do
  use ExUnit.Case
  doctest Mensendi.Segments.ERR

  test "gets the right data from the raw segment" do
    segment = Mensendi.Data.Segment.from_string(
      "ERR||PID^5|101^required field missing^HL70357|E",
      %Mensendi.Data.Delimiters{}
    )
    |> Mensendi.Segments.ERR.from_segment

    assert List.first(segment.code_and_location) == %Mensendi.DataTypes.ELD{}
    assert List.first(segment.location) == %Mensendi.DataTypes.ERL{
      segment_id: %Mensendi.DataTypes.ST{value: "PID"},
      segment_sequence: %Mensendi.DataTypes.NM{value: 5.0}
    }
    assert List.first(segment.hl7_error_code) == %Mensendi.DataTypes.CWE{
      identifier: Mensendi.DataTypes.ST.from_string("101"),
      text: Mensendi.DataTypes.ST.from_string("required field missing"),
      name_of_coding_system: Mensendi.DataTypes.ID.from_string("HL70357")
    }
    assert segment.severity == [Mensendi.DataTypes.ID.from_string("E")]
  end
end
