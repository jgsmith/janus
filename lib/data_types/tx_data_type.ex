defmodule TXDataType do
  @type t :: %TXDataType{value: String.t}

  defstruct [value: ""]

  @spec from_field(Mensendi.Data.Field.t) :: t
  def from_field(field) do
    field
    |> Mensendi.Data.Field.to_string
    |> from_string
  end

  @spec from_component(Mensendi.Data.Component.t) :: t
  def from_component(component) do
    component
    |> Mensendi.Data.Component.to_string(%Mensendi.Data.Delimiters{})
    |> from_string
  end

  @spec from_string(String.t) :: t
  def from_string(string) do
    %TXDataType{value: string}
  end
end
