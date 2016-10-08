defmodule ISDataType do
  @type t :: %ISDataType{value: String.t}

  defstruct [value: ""]

  @spec from_field(Mensendi.Data.Field.t) :: t
  def from_field(field) do
    %ISDataType{value: Mensendi.Data.Field.to_string(field)}
  end

  @spec from_component(Mensendi.Data.Component.t) :: t
  def from_component(component) do
    %ISDataType{value: Mensendi.Data.Component.to_string(component, %Mensendi.Data.Delimiters{})}
  end
end
