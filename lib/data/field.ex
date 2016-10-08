defmodule Mensendi.Data.Field do
  alias Mensendi.Data.Component, as: Component
  alias Mensendi.Data.Delimiters, as: Delimiters
  alias Mensendi.Data.Field, as: Field

  @type t :: %Field{components: List}

  defstruct [components: []]

  def from_string(text, delimiters) do
    %Field{
      components: (
        text
        |> String.trim_trailing(delimiters.components)
        |> String.split(delimiters.components)
        |> Enum.map(&(Component.from_string(&1, delimiters)))
      )
    }
  end

  def to_string(foo, delimiters \\ %Delimiters{})

  def to_string(fields, delimiters) when is_list(fields) do
    fields |> Enum.map_join(delimiters.repetitions, &(to_string(&1, delimiters)))
  end

  def to_string(field, delimiters) when not is_list(field) do
    field.components
    |> Enum.map_join(delimiters.components, &(Component.to_string(&1, delimiters)))
  end

  def get_component(field, number) do
    Access.get(field.components, number, %Component{})
  end
end
