defmodule Mensendi.DataTypes.IS do
  alias Mensendi.Data.{Component, Field}
  alias Mensendi.DataTypes.IS

  @type t :: %IS{value: String.t}

  defstruct [value: ""]

  @spec from_field(Field.t) :: t
  def from_field(field) do
    %IS{value: Field.to_string(field)}
  end

  @spec from_component(Component.t) :: t
  def from_component(component) do
    %IS{value: Component.to_string(component)}
  end
end
