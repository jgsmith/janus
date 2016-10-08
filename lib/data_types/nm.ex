defmodule Mensendi.DataTypes.NM do
  alias Mensendi.DataTypes.{NM, ST}

  @type t :: %NM{value: Float}

  defstruct [value: Float]

  def from_field(field) do
    field
    |> ST.from_field
    |> to_float
  end

  def from_component(component) do
    component
    |> ST.from_component
    |> to_float
  end

  def from_string(string) do
    to_float(string)
  end

  defp to_float(string) do
    float_string = cond do
      string.value == ""                  -> ""
      String.contains?(string.value, ".") -> string.value <> "0"
      true                                -> string.value <> ".0"
    end

    if float_string == "" do
      ""
    else
      %NM{value: String.to_float(float_string)}
    end
  end
end
