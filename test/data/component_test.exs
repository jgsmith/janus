defmodule ComponentTest do
  use ExUnit.Case
  doctest Component

  test "from_string" do
    component = Component.from_string("abc&def", %Delimiters{})
    assert component.subcomponents == {"abc", "def"}
  end

  test "to_string" do
    component = %Component{subcomponents: {"abc", "def"}}

    assert Component.to_string(component, %Delimiters{}) == "abc&def"
  end
end
