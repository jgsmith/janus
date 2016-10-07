defmodule ISDataType do
  @type t :: %ISDataType{value: String.t}

  defstruct [value: ""]

  @spec from_field(Field.t) :: t
  def from_field(field) do
    %ISDataType{value: Field.to_string(field)}
  end

  @spec from_component(Component.t) :: t
  def from_component(component) do
    %ISDataType{value: Component.to_string(component, %Delimiters{})}
  end
end
