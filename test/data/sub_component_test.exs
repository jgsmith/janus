defmodule SubComponentTest do
  use ExUnit.Case
  doctest SubComponent

  test "from_string with no escapes necessary" do
    assert SubComponent.decoded("abc", %Delimiters{}) == "abc"
  end

  test "from_string with \\F\\" do
    assert SubComponent.decoded("abc\\F\\def", %Delimiters{})
            == "abc|def"
  end

  test "from_string with \\E\\" do
    assert SubComponent.decoded("abc\\E\\def", %Delimiters{})
            == "abc\\def"
  end

  test "to_string with no escapes" do
    assert SubComponent.encoded("abc", %Delimiters{}) == "abc"
  end

  test "to_string with \\" do
    assert SubComponent.encoded("abc\\e", %Delimiters{}) == "abc\\E\\e"
  end

  test "to_string with ~" do
    assert SubComponent.encoded("abc~e", %Delimiters{}) == "abc\\R\\e"
  end
end
