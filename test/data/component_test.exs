defmodule Mensendi.Data.ComponentTest do
  use ExUnit.Case
  doctest Mensendi.Data.Component

  test "from_string" do
    component = Mensendi.Data.Component.from_string("abc&def", %Mensendi.Data.Delimiters{})
    assert component.subcomponents == {"abc", "def"}
  end

  test "to_string" do
    component = %Mensendi.Data.Component{subcomponents: {"abc", "def"}}

    assert Mensendi.Data.Component.to_string(component, %Mensendi.Data.Delimiters{}) == "abc&def"
  end
end
