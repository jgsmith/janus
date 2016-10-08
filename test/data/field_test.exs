defmodule Mensendi.Data.FieldTest do
  use ExUnit.Case
  doctest Mensendi.Data.Field

  test "from_string" do
    field = Mensendi.Data.Field.from_string("abc^def", %Mensendi.Data.Delimiters{})
    assert Enum.map(field.components, &(Mensendi.Data.Component.to_string(&1, %Mensendi.Data.Delimiters{}))) == [ "abc", "def" ]
  end

  test "to_string" do
    field = %Mensendi.Data.Field{
      components: [
        %Mensendi.Data.Component{subcomponents: {"abc", "def"}},
        %Mensendi.Data.Component{subcomponents: {"uvw", "xyz"}}
      ]
    }

    assert Mensendi.Data.Field.to_string(field, %Mensendi.Data.Delimiters{}) == "abc&def^uvw&xyz"
  end
end
