defmodule Message do
  @type t :: %Message{
    segments: List,
    delimiters: Delimiters.t
  }

  defstruct [segments: [], delimiters: %Delimiters{}]

  @spec with_delimiters(Message.t, Delimiters.t) :: Message.t
  def with_delimiters(message, delimiters) do
    %Message{message | delimiters: delimiters}
  end

  @spec from_string(String.t) :: Message.t
  def from_string(text) do
    cond do
      String.starts_with?(text, "MSH") ->
        delimiters = %Delimiters{}
          |> Delimiters.with_fields(String.at(text, 3))            # |
          |> Delimiters.with_components(String.at(text, 4))        # ^
          |> Delimiters.with_repetitions(String.at(text, 5))       # ~
          |> Delimiters.with_escapes(String.at(text, 6))           # \
          |> Delimiters.with_subcomponents(String.at(text, 7))     # &

        segments = text
          |> String.trim_trailing(delimiters.segments)
          |> String.split(delimiters.segments)
          |> Enum.map(&(Segment.from_string(&1, delimiters)))

        { :ok,
          %Message{
            delimiters: delimiters,
            segments: segments
          }
        }
      true -> { :error, "First segment is not MSH" }
    end
  end

  @spec to_string(Message.t) :: String.t
  def to_string(message) do
    message.segments
    |> Enum.map(&(Segment.to_string(&1, message.delimiters)))
    |> Enum.filter(
         fn(x) ->
           is_binary(x) and x != ""
         end
      )
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
    case message |> build_structure(structure) do
      {:ok, new_message} -> {:ok, new_message }
      {:error, stuff} -> {:error, stuff}
    end
  end

  @spec build_structure(Message.t, String.t) :: List
  defp build_structure(message, structure) do
    case structure
         |> MessageGrammar.compile
         |> MessageGrammar.parse(message.segments)
    do
      {:ok, {list, []}} -> {:ok, %Message{delimiters: message.delimiters, segments: list}}
      {:error, stuff} -> {:error, stuff}
    end
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
