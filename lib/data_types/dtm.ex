defmodule Mensendi.DataTypes.DTM do
  alias Mensendi.Data.{Component, Field}
  alias Mensendi.DataTypes.DTM
  require Timex

  @type t :: %DTM{value: String.t, datetime: DateTime | nil}

  defstruct [value: "", datetime: nil]

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
  def from_string("") do
    %DTM{value: "", datetime: nil}
  end

  def from_string(string) do
    %DTM{value: string, datetime: to_datetime(string)}
  end

  def as_string(%DTM{datetime: nil}), do: ""

  def as_string(%DTM{datetime: datetime}) do
    Timex.format(datetime, "{ASN1:GeneralizedTime:TZ}")
  end

  def in_timezone(_dtm, _tz) do

  end

  defp to_datetime(string) do
    # YYYYMMDDHHMMSS+-ZZZZ
    Timex.parse(string, "{ASN1:GeneralizedTime:TZ}")
  end
end
