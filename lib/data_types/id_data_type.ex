defmodule IDDataType do
  @type t :: %IDDataType{value: String.t}

  defstruct [value: ""]

  @spec from_field(Mensendi.Data.Field.t) :: t
  def from_field(field) do
    %IDDataType{value: Mensendi.Data.Field.to_string(field)}
  end

  @spec from_component(Mensendi.Data.Component.t) :: t
  def from_component(component) do
    %IDDataType{value: Mensendi.Data.Component.to_string(component, %Mensendi.Data.Delimiters{})}
  end

  @spec from_string(String.t) :: t
  def from_string(string) do
    %IDDataType{value: string}
  end
end
