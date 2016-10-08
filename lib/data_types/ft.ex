defmodule Mensendi.DataTypes.FT do
  alias Mensendi.Data.Component, as: Component
  alias Mensendi.Data.Field, as: Field
  alias Mensendi.DataTypes.FT, as: FT

  @type t :: %FT{value: String.t}

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
    |> Component.to_string
    |> from_string
  end

  @spec from_string(String.t) :: t
  def from_string(string) do
    %FT{value: string}
  end
end
