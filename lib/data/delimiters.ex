defmodule Mensendi.Data.Delimiters do
  @moduledoc """
  Represents the various delimiters used in HL7 messages.

  *N.B.:* This does not manage the delimiters used in MLLP framing.
  See `Mensendi.Data.MLLPBuffer` for managing MLLP framing.
  """

  alias Mensendi.Data.Delimiters

  @type t :: %Delimiters{
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

  @doc """
  Returns a binary (string) representation of the delimiters as they are placed in
  the MSH, BHS, and FHS segments. Field and segment separators are not included in this
  string.
  ## Example
      iex> alias Mensendi.Data.Delimiters
      iex> delimiters = %Delimiters{}
      iex> delimiters |> Delimiters.to_string
      "^~\\\\&"
  """
  @spec to_string(Delimiters.t) :: String.t
  def to_string(delimiters) do
    delimiters.components
    <> delimiters.repetitions
    <> delimiters.escapes
    <> delimiters.subcomponents
  end

  @doc """
  Returns a new delimiter structure with the segment separator set to the given value.
  ## Example
      iex> alias Mensendi.Data.Delimiters
      iex> delimiters = %Delimiters{}
      iex> (delimiters |> Delimiters.with_segments("\\n")).segments
      "\\n"
  """
  @spec with_segments(Delimiters.t, String.t) :: Delimiters.t
  def with_segments(delimiters, segment_separator) do
    %Delimiters{delimiters | segments: segment_separator}
  end

  @doc """

  ## Example
      iex> alias Mensendi.Data.Delimiters
      iex> delimiters = %Delimiters{}
      iex> (delimiters |> Delimiters.with_fields("F")).fields
      "F"
  """
  @spec with_fields(Delimiters.t, String.t) :: Delimiters.t
  def with_fields(delimiters, s) do
    %Delimiters{delimiters | fields: s}
  end

  @doc """

  ## Example
      iex> alias Mensendi.Data.Delimiters
      iex> delimiters = %Delimiters{}
      iex> delimiters |> Delimiters.with_components("C") |> Delimiters.to_string
      "C~\\\\&"
  """
  @spec with_components(Delimiters.t, String.t) :: Delimiters.t
  def with_components(delimiters, s) do
    %Delimiters{delimiters | components: s}
  end

  @doc """

  ## Example
      iex> alias Mensendi.Data.Delimiters
      iex> delimiters = %Delimiters{}
      iex> delimiters |> Delimiters.with_subcomponents("S") |> Delimiters.to_string
      "^~\\\\S"
  """
  @spec with_subcomponents(Delimiters.t, String.t) :: Delimiters.t
  def with_subcomponents(delimiters, s) do
    %Delimiters{delimiters | subcomponents: s}
  end

  @doc """

  ## Example
      iex> alias Mensendi.Data.Delimiters
      iex> delimiters = %Delimiters{}
      iex> delimiters |> Delimiters.with_repetitions("R") |> Delimiters.to_string
      "^R\\\\&"
  """
  @spec with_repetitions(Delimiters.t, String.t) :: Delimiters.t
  def with_repetitions(delimiters, s) do
    %Delimiters{delimiters | repetitions: s}
  end

  @doc """

  ## Example
      iex> alias Mensendi.Data.Delimiters
      iex> delimiters = %Delimiters{}
      iex> delimiters |> Delimiters.with_escapes("E") |> Delimiters.to_string
      "^~E&"
  """
  @spec with_escapes(Delimiters.t, String.t) :: Delimiters.t
  def with_escapes(delimiters, s) do
    %Delimiters{delimiters | escapes: s}
  end
end
