defmodule DTDataType do
  alias Mensendi.Data.Component, as: Component
  alias Mensendi.Data.Field, as: Field

  @type t :: %DTDataType{value: String.t, date: Date | nil}

  defstruct [value: "", date: nil]

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
    %DTDataType{value: string, date: to_date(string)}
  end

  defp to_date(string) do
    # YYYYMMDDHHMMSS+-ZZZZ
    year  = string |> String.slice(0, 4) |> maybe_integer
    month = string |> String.slice(4, 2) |> maybe_integer(1)
    day   = string |> String.slice(6, 2) |> maybe_integer(1)

    Timex.to_date({{year, month, day}})
  end

  defp maybe_integer(string, default \\ nil) do
    if string in ["", nil] do
      default
    else
      String.to_integer(string)
    end
  end
end
