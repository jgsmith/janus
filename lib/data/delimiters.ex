defmodule Mensendi.Data.Delimiters do
  @type t :: %Mensendi.Data.Delimiters{
    segments: String.t,
    fields: String.t,
    components: String.t,
    subcomponents: String.t,
    repetitions: String.t,
    escapes: String.t
  }

  defstruct [
    segments: "\r",
    fields: "|",
    components: "^",
    subcomponents: "&",
    repetitions: "~",
    escapes: "\\"
  ]

  def to_string(delimiters) do
    delimiters.components
    <> delimiters.repetitions
    <> delimiters.escapes
    <> delimiters.subcomponents
  end

  def with_segments(delimiters, s) do
    %Mensendi.Data.Delimiters{delimiters | segments: s}
  end

  def with_fields(delimiters, s) do
    %Mensendi.Data.Delimiters{delimiters | fields: s}
  end

  def with_components(delimiters, s) do
    %Mensendi.Data.Delimiters{delimiters | components: s}
  end

  def with_subcomponents(delimiters, s) do
    %Mensendi.Data.Delimiters{delimiters | subcomponents: s}
  end

  def with_repetitions(delimiters, s) do
    %Mensendi.Data.Delimiters{delimiters | repetitions: s}
  end

  def with_escapes(delimiters, s) do
    %Mensendi.Data.Delimiters{delimiters | escapes: s}
  end
end
