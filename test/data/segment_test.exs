defmodule Mensendi.Data.SegmentTest do
  use ExUnit.Case
  alias Mensendi.Data.{Component, Delimiters, Field, Segment}
  doctest Segment

  test "from_string" do
    segment = Segment.from_string(
      "PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789|||"
    )

    # we don't count empty fields on the end of the segment
    assert Enum.count(segment.fields) == 20

    # we can at least get back what we started with
    assert Segment.to_string(segment, %Delimiters{}) ==
            "PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789"
  end

  test "to_string" do
    segment = %Segment{
      segment_name: "ZZZ",
      fields: [
        [%Field{components: [%Component{subcomponents: {"ZZZ"}}]}],
        [%Field{}],
        [%Field{}],
        [%Field{components: [%Component{subcomponents: {"ABC","123"}}]}],
        [%Field{components: [%Component{subcomponents: {"foo"}}, %Component{subcomponents: {"bar"}}]}],
        [%Field{components: [%Component{subcomponents: {"baz"}}]},
         %Field{components: [%Component{subcomponents: {"bat"}}]}]
      ]
    }

    assert Segment.to_string(segment, %Delimiters{
        fields: "!",
        components: "@",
        subcomponents: "#",
        repetitions: "$"
      }) ==
      "ZZZ!!!ABC#123!foo@bar!baz$bat"
  end

  test "Enum.count" do
    segment = %Segment{
      segment_name: "ZZZ",
      children: [%Segment{segment_name: "ZZY", children: [%Segment{segment_name: "ZZW"}]}],
      fields: [
        [%Field{components: [%Component{subcomponents: {"ZZZ"}}]}],
        [%Field{}],
        [%Field{}],
        [%Field{components: [%Component{subcomponents: {"ABC","123"}}]}],
        [%Field{components: [%Component{subcomponents: {"foo"}}, %Component{subcomponents: {"bar"}}]}],
        [%Field{components: [%Component{subcomponents: {"baz"}}]},
         %Field{components: [%Component{subcomponents: {"bat"}}]}]
      ]
    }

    assert Enum.count(segment) == 2
  end
end
