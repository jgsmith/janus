defmodule Mensendi.DataTypes.ID do
  alias Mensendi.Data.{Component, Field}
  alias Mensendi.DataTypes.ID

  @type t :: %ID{value: String.t}

  defstruct [value: ""]

  @spec from_field(Field.t) :: t
  def from_field(field) do
    %ID{value: Field.to_string(field)}
  end

  @spec from_component(Component.t) :: t
  def from_component(component) do
    %ID{value: Component.to_string(component)}
  end

  @spec from_string(String.t) :: t
  def from_string(string) do
    %ID{value: string}
  end
end
