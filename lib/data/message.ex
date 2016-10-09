defmodule Mensendi.Data.Message do
  alias Mensendi.Data.{Delimiters, Message, Segment}

  @type t :: %Message{
    segments: List,
    delimiters: Mensendi.Data.Delimiters.t
  }

  defstruct [segments: [], delimiters: %Delimiters{}]

  @spec with_delimiters(Message.t, Delimiters.t) :: Message.t
  def with_delimiters(message, delimiters) do
    %Message{message | delimiters: delimiters}
  end

  def from_string(raw_hl7)

  @spec from_string(String.t) :: {:ok, Message.t} | {:error, String.t}
  def from_string(text =  <<
                            "MSH",
                            fields        :: bytes-size(1),
                            components    :: bytes-size(1),
                            repetitions   :: bytes-size(1),
                            escapes       :: bytes-size(1),
                            subcomponents :: bytes-size(1),
                            _ :: binary
                          >>) do

    delimiters =
      %Delimiters{}
      |> Delimiters.with_fields(fields)               # |
      |> Delimiters.with_components(components)       # ^
      |> Delimiters.with_repetitions(repetitions)     # ~
      |> Delimiters.with_escapes(escapes)             # \
      |> Delimiters.with_subcomponents(subcomponents) # &

    segments =
      text
      |> String.trim_trailing(delimiters.segments)
      |> String.split(delimiters.segments)
      |> Enum.map(&(Segment.from_string(&1, delimiters)))

    { :ok,
      %Message{
        delimiters: delimiters,
        segments: segments
      }
    }
  end

  def from_string(<<"MSH", _ :: binary>>) do
    {:error, "First segment is MSH but not long enough"}
  end

  def from_string(_) do
    {:error, "First segment is not MSH"}
  end

  @spec to_string(Message.t) :: String.t
  def to_string(message) do
    message.segments
    |> Stream.map(&(Segment.to_string(&1, message.delimiters)))
    |> Stream.filter(&(is_binary(&1) and &1 != ""))
    |> Enum.join(message.delimiters.segments)
  end

  @spec with_structure(Message.t, String.t) :: Message.t
  def with_structure(message, structure) do
    # example structure:
    #
    # MSH ... <PID ... {PV1}>
    #
    # we always want to solve for "message"
    #
    # as long as we can fit the structure to the message, we'll pass it along
    # if there are segments we don't know about, or don't fit, we ignore them
    message
    |> build_structure(structure)
  end

  @spec build_structure(Message.t, String.t) :: List
  defp build_structure(message, structure) do
    structure
    |> MessageGrammar.compile
    |> MessageGrammar.parse(message.segments)
    |> finalize_structure(message.delimiters)
  end

  defp finalize_structure({:ok, {list, []}}, delimiters) do
    {:ok, %Message{delimiters: delimiters, segments: list}}
  end

  defp finalize_structure({:ok, segments = {_, _}}, _) do
    {:error, segments}
  end

  defp finalize_structure(everything = {:error, _}, _) do
    everything
  end

  @spec segments(Message.t, String.t) :: List
  def segments(message, name) when is_binary(name) do
    segments(message, [name])
  end

  @spec segments(Message.t, List | MapSet) :: List
  def segments(message, names) when not is_binary(names) do
    set = MapSet.new(names)
    Enum.filter(message.segments, &(MapSet.member?(set, &1.name)))
  end
end
