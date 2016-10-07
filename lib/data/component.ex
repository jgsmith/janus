defmodule Component do
  @type t :: %Component{subcomponents: Tuple}

  defstruct [subcomponents: {}]

  @spec from_string(String.t, Delimiters.t) :: t
  def from_string(text, delimiters) do
    %Component{
      subcomponents: (
        text
        |> String.trim_trailing(delimiters.subcomponents)
        |> String.split(delimiters.subcomponents)
        |> Enum.map(&(SubComponent.decoded(&1, delimiters)))
        |> List.to_tuple
      )
    }
  end

  def to_string(component, delimiters) do
    component.subcomponents
    |> Tuple.to_list
    |> Enum.map_join(delimiters.subcomponents, &(SubComponent.encoded(&1, delimiters)))
  end

  def get_subcomponent(component, number) do
    Access.get(component.subcomponents, number, {})
  end
end
