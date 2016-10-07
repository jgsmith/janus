defmodule DTMDataType do
  @type t :: %DTMDataType{value: String.t, datetime: DateTime | nil}

  defstruct [value: "", datetime: nil]

  @spec from_field(Field.t) :: t
  def from_field(field) do
    field |> Field.to_string |> from_string
  end

  @spec from_component(Component.t) :: t
  def from_component(component) do
    component |> Component.to_string(%Delimiters{}) |> from_string
  end

  @spec from_string(String.t) :: t
  def from_string(string) do
    %DTMDataType{value: string, datetime: to_datetime(string)}
  end

  def in_timezone(dtm, tz) do

  end

  defp to_datetime(string) do
    # YYYYMMDDHHMMSS+-ZZZZ
    year = string |> String.slice(0, 4) |> maybe_integer
    month = string |> String.slice(4, 2) |> maybe_integer(1)
    day = string |> String.slice(6, 2) |> maybe_integer(1)
    hour = string |> String.slice(8, 2) |> maybe_integer(0)
    minute = string |> String.slice(10, 2) |> maybe_integer(0)
    second = string |> String.slice(12, 2) |> maybe_integer(0)
    tz = string |> String.slice(14, 5)

    Timex.to_datetime({
      {year, month, day},
      {hour, minute, second}
    }, "UTC")
  end

  defp maybe_integer(string, default \\ nil) do
    case string do
      "" -> default
      nil -> default
      _ -> String.to_integer(string)
    end
  end
end
