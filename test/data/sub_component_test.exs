defmodule Mensendi.Data.SubComponentTest do
  use ExUnit.Case
  doctest Mensendi.Data.SubComponent

  test "from_string with no escapes necessary" do
    assert Mensendi.Data.SubComponent.decoded("abc", %Mensendi.Data.Delimiters{}) == "abc"
  end

  test "from_string with \\F\\" do
    assert Mensendi.Data.SubComponent.decoded("abc\\F\\def", %Mensendi.Data.Delimiters{})
            == "abc|def"
  end

  test "from_string with \\E\\" do
    assert Mensendi.Data.SubComponent.decoded("abc\\E\\def", %Mensendi.Data.Delimiters{})
            == "abc\\def"
  end

  test "to_string with no escapes" do
    assert Mensendi.Data.SubComponent.encoded("abc", %Mensendi.Data.Delimiters{}) == "abc"
  end

  test "to_string with \\" do
    assert Mensendi.Data.SubComponent.encoded("abc\\e", %Mensendi.Data.Delimiters{}) == "abc\\E\\e"
  end

  test "to_string with ~" do
    assert Mensendi.Data.SubComponent.encoded("abc~e", %Mensendi.Data.Delimiters{}) == "abc\\R\\e"
  end
end
