defmodule Mensendi.DataTypes.DT do
  alias Mensendi.Data.{Component, Field}
  alias Mensendi.DataTypes.DT
  require Timex

  @type t :: %DT{value: String.t, date: Date | nil}

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
    %DT{value: string, date: to_date(string)}
  end

  def as_string(%DT{date: nil}), do: ""

  def as_string(%DT{date: date}) do
    date
    |> Timex.format("{ASN1:GeneralizedTime}")
    |> String.slice(0,8)
  end

  defp to_date(string) do
    # YYYYMMDDHHMMSS+-ZZZZ
    Timex.parse(string, "{ASN1:GeneralizedTime}")
  end
end
