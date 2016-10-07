defmodule NMDataType do
  @type t :: %NMDataType{value: Float}

  defstruct [value: Float]

  def from_field(field) do
    field
    |> STDataType.from_field
    |> to_float
  end

  def from_component(component) do
    component
    |> STDataType.from_component
    |> to_float
  end

  def from_string(string) do
    to_float(string)
  end

  defp to_float(string) do
    float_string = cond do
      string.value == "" -> ""
      String.contains?(string.value, ".") -> string.value <> "0"
      true                          -> string.value <> ".0"
    end

    case float_string do
      "" -> string
      _ -> %NMDataType{value: String.to_float(float_string)}
    end
  end
end
