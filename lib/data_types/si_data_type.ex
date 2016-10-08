defmodule SIDataType do
  @type t :: %SIDataType{value: Integer}

  defstruct [value: Integer]

  def from_field(field) do
    field
    |> STDataType.from_field
    |> to_integer
  end

  def from_component(component) do
    component
    |> STDataType.from_component
    |> to_integer
  end

  def from_string(string) do
    to_integer(string)
  end

  defp to_integer(string) do
    int_string = cond do
      string.value == ""                  -> ""
      String.contains?(string.value, ".") -> string.value <> "0"
      true                                -> string.value <> ".0"
    end

    if int_string == "" do
      ""
    else
      %SIDataType{value: int_string |> String.to_float |> trunc}
    end
  end
end
