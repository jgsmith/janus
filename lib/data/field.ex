defmodule Mensendi.Data.Field do
  @type t :: %Mensendi.Data.Field{components: List}

  defstruct [components: []]

  def from_string(text, delimiters) do
    %Mensendi.Data.Field{
      components: (
        text
        |> String.trim_trailing(delimiters.components)
        |> String.split(delimiters.components)
        |> Enum.map(&(Mensendi.Data.Component.from_string(&1, delimiters)))
      )
    }
  end

  def to_string(foo, delimiters \\ %Mensendi.Data.Delimiters{})

  def to_string(fields, delimiters) when is_list(fields) do
    fields |> Enum.map_join(delimiters.repetitions, &(to_string(&1, delimiters)))
  end

  def to_string(field, delimiters) when not is_list(field) do
    field.components
    |> Enum.map_join(delimiters.components, &(Mensendi.Data.Component.to_string(&1, delimiters)))
  end

  def get_component(field, number) do
    Access.get(field.components, number, %Mensendi.Data.Component{})
  end
end
