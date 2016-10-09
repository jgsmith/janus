defmodule Mensendi.Data.Component do
  alias Mensendi.Data.{Component, Delimiters, SubComponent}

  @type t :: %Component{subcomponents: Tuple}

  defstruct [subcomponents: {}]

  @doc """
  Decomposes a string representing an HL7 component.

  ## Example
      iex> Component.from_string("foo&h\\\\S\\\\20&baz", %Delimiters{})
      %Component{subcomponents: {"foo", "h^20", "baz"}}
  """
  @spec from_string(String.t, Delimiters.t) :: __MODULE__.t
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

  @doc """
  Returns a proper serialization of the component with escaped delimiters.

  ## Example
      iex> Component.to_string(%Component{subcomponents: {"foo", "h^20", "baz"}})
      "foo&h\\\\S\\\\20&baz"
  """
  @spec to_string(__MODULE__.t, Delimiters.t) :: String.t
  def to_string(component, delimiters \\ %Delimiters{}) do
    component.subcomponents
    |> Tuple.to_list
    |> Enum.map_join(delimiters.subcomponents, &(SubComponent.encoded(&1, delimiters)))
  end

  @doc """
  Returns the subcomponent at the given index.

  ## Example
      iex> Component.get_subcomponent(%Component{subcomponents: {"apple", "banana", "citrus"}}, 1)
      "banana"
      iex> Component.get_subcomponent(%Component{subcomponents: {"apple", "banana", "citrus"}}, 5)
      ""
  """
  @spec get_subcomponent(__MODULE__.t, Integer) :: String.t
  def get_subcomponent(component, index)

  def get_subcomponent(%{subcomponents: subcomponents}, index) when tuple_size(subcomponents) > index do
    elem(subcomponents, index)
  end

  def get_subcomponent(_, _) do
    ""
  end
end
