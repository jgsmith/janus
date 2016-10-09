defmodule Mensendi.Data.FieldTest do
  use ExUnit.Case
  alias Mensendi.Data.{Component, Delimiters, Field}
  doctest Field

  test "from_string" do
    field = Field.from_string("abc$def", %Delimiters{components: "$"})
    assert Enum.map(field.components, &(Component.to_string(&1, %Delimiters{}))) == [ "abc", "def" ]
  end

  test "to_string" do
    field = %Field{
      components: [
        %Component{subcomponents: {"abc", "def"}},
        %Component{subcomponents: {"uvw", "xyz"}}
      ]
    }

    # creates a string and honors the settings in delimiters
    assert Field.to_string(
      field,
      %Delimiters{subcomponents: ",", components: ";"}
    ) == "abc,def;uvw,xyz"
  end
end
