defmodule Mensendi.Segments.ERRTest do
  use ExUnit.Case
  alias Mensendi.Data.Segment
  alias Mensendi.DataTypes.{CWE, ELD, ERL, ID, NM, ST}
  alias Mensendi.Segments.ERR
  doctest ERR

  test "gets the right data from the raw segment" do
    segment =
      "ERR||PID^5|101^required field missing^HL70357|E"
      |> Segment.from_string
      |> ERR.from_segment

    assert List.first(segment.code_and_location) == %ELD{}
    assert List.first(segment.location) == %ERL{
      segment_id: %ST{value: "PID"},
      segment_sequence: %NM{value: 5.0}
    }
    assert List.first(segment.hl7_error_code) == %CWE{
      identifier: ST.from_string("101"),
      text: ST.from_string("required field missing"),
      name_of_coding_system: ID.from_string("HL70357")
    }
    assert segment.severity == [ID.from_string("E")]
  end
end
