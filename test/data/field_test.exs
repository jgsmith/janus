defmodule FieldTest do
  use ExUnit.Case
  doctest Field

  test "from_string" do
    field = Field.from_string("abc^def", %Delimiters{})
    assert Enum.map(field.components, &(Component.to_string(&1, %Delimiters{}))) == [ "abc", "def" ]
  end

  test "to_string" do
    field = %Field{
      components: [
        %Component{subcomponents: {"abc", "def"}},
        %Component{subcomponents: {"uvw", "xyz"}}
      ]
    }

    assert Field.to_string(field, %Delimiters{}) == "abc&def^uvw&xyz"
  end
end
