defmodule STDataType do
  @type t :: %STDataType{value: String.t}

  defstruct [value: ""]

  @spec from_field(Field.t) :: t
  def from_field(field) do
    field
    |> Field.to_string
    |> from_string
  end

  @spec from_component(Component.t) :: t
  def from_component(component) do
    component
    |> Component.to_string(%Delimiters{})
    |> from_string
  end

  @spec from_string(String.t) :: t
  def from_string(string) do
    %STDataType{value: string}
  end
end
