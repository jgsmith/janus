defmodule Mensendi.DataTypes.TX do
  alias Mensendi.Data.{Component, Field}
  alias Mensendi.DataTypes.TX

  @type t :: %TX{value: String.t}

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
    %TX{value: string}
  end

  def as_string(%{value: value}), do: value

  def to_field(st) do
    %Field{
      components: [
        to_component(st)
      ]
    }
  end

  def to_component(%{value: value} = _st) do
    %Component{
      subcomponents: {value}
    }
  end
end
