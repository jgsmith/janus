defmodule Mensendi.Data.SegmentTest do
  use ExUnit.Case
  doctest Mensendi.Data.Segment

  test "from_string" do
    segment = Mensendi.Data.Segment.from_string(
      "PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789|||",
      %Mensendi.Data.Delimiters{}
    )

    # we don't count empty fields on the end of the segment
    assert Enum.count(segment.fields) == 20

    # we can at least get back what we started with
    assert Mensendi.Data.Segment.to_string(segment, %Mensendi.Data.Delimiters{}) ==
            "PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789"
  end

  test "to_string" do
    segment = %Mensendi.Data.Segment{
      name: "ZZZ",
      fields: [
        [%Mensendi.Data.Field{components: [%Mensendi.Data.Component{subcomponents: {"ZZZ"}}]}],
        [%Mensendi.Data.Field{}],
        [%Mensendi.Data.Field{}],
        [%Mensendi.Data.Field{components: [%Mensendi.Data.Component{subcomponents: {"ABC","123"}}]}],
        [%Mensendi.Data.Field{components: [%Mensendi.Data.Component{subcomponents: {"foo"}}, %Mensendi.Data.Component{subcomponents: {"bar"}}]}],
        [%Mensendi.Data.Field{components: [%Mensendi.Data.Component{subcomponents: {"baz"}}]},
         %Mensendi.Data.Field{components: [%Mensendi.Data.Component{subcomponents: {"bat"}}]}]
      ]
    }

    assert Mensendi.Data.Segment.to_string(segment, %Mensendi.Data.Delimiters{}) ==
      "ZZZ|||ABC&123|foo^bar|baz~bat"
  end
end
