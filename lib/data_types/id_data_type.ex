defmodule IDDataType do
  alias Mensendi.Data.Component, as: Component
  alias Mensendi.Data.Field, as: Field

  @type t :: %IDDataType{value: String.t}

  defstruct [value: ""]

  @spec from_field(Field.t) :: t
  def from_field(field) do
    %IDDataType{value: Field.to_string(field)}
  end

  @spec from_component(Component.t) :: t
  def from_component(component) do
    %IDDataType{value: Component.to_string(component)}
  end

  @spec from_string(String.t) :: t
  def from_string(string) do
    %IDDataType{value: string}
  end
end
