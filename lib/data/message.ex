defmodule Mensendi.Data.Message do
  alias Mensendi.Data.{Delimiters, Message, Segment}
  alias Mensendi.Utils.MessageGrammar

  use OkJose

  @type t :: %Message{
    segments: List,
    delimiters: Mensendi.Data.Delimiters.t
  }

  defstruct [segments: [], delimiters: %Delimiters{}]

  @doc """
  Sets the delimiter set that the message will use during serialization.
  """
  @spec with_delimiters(Message.t, Delimiters.t) :: Message.t
  def with_delimiters(message, delimiters) do
    %Message{message | delimiters: delimiters}
  end

  @doc """
  Parses a utf-8 string into a raw message structure.

  The resulting message object uses the same delimiters for serialization
  as were used when sending the message.
  """
  @spec from_string(String.t) :: {:ok, Message.t} | {:error, String.t}
  def from_string(raw_hl7)

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

    { :ok,
      text
      |> String.trim_trailing(delimiters.segments)
      |> String.split(delimiters.segments)
      |> Stream.map(&(Segment.from_string(&1, delimiters)))
      |> Enum.into(%Message{delimiters: delimiters})
    }
  end

  def from_string(<<"MSH", _ :: binary>>) do
    {:error, "First segment is MSH but not long enough"}
  end

  def from_string(_) do
    {:error, "First segment is not MSH"}
  end

  @doc """
  Structures the message according to the documented description.

  Given a message and a list of module prefixes, this will find the module that holds the
  description of the structure for the messages's event code and type. The path is useful
  for selectively overriding the HL7v2.5 standard structure for particular sites.
  """
  @spec structure_message(Message.t, [atom]) :: {:ok, Message.t} | {:error, String.t}
  def structure_message(message, path) do
    # the module_path gives us a way to look for site-specific message formats
    msh =
      message
      |> Message.segments("MSH")
      |> List.first
      |> Mensendi.Segments.MSH.from_segment

    message_type = List.first(msh.message_type).message_code.value
    trigger_code = List.first(msh.message_type).trigger_event.value
    case find_structure(message_type, trigger_code, path) do
      {:ok, structure} ->
        {:ok, message}
        |> with_structure(structure)
        |> with_structured_segments
        |> ok
      anything_else -> anything_else
    end
  end

  defp find_structure(type, code, []) do
    {:error, "No message structures found for #{type}/#{code}"}
  end

  defp find_structure(type, code, [prefix | rest]) do
    module = Module.concat([prefix, type])
    if Code.ensure_loaded?(module) do
      case module.find_message_event(code) do
        {:error, _}   -> find_structure(type, code, rest)
        {:ok, %{message_structure: structure}} -> {:ok, structure}
      end
    else
      find_structure(type, code, rest)
    end
  end

  @spec with_structure(Message.t, String.t | MessageGrammar.t) :: {:ok, Message.t} | {:error, String.t}
  def with_structure(message, structure) when is_binary(structure) do
    with compiled <- MessageGrammar.compile(structure) do
      with_structure(message, compiled)
    end
  end

  def with_structure(message, structure) do
    MessageGrammar.parse(structure, message.segments)
    |> finalize_structure(message.delimiters)
  end

  @spec with_structured_segments(Message.t) :: Message.t
  def with_structured_segments(message) do
    {:ok,
      %{message |
        segments: message.segments
                  |> Enum.map(&Segment.to_structured_segment/1)
      }
    }
  end

  defp finalize_structure({:ok, {list, []}}, delimiters) do
    {:ok, %Message{delimiters: delimiters, segments: list}}
  end

  defp finalize_structure({:ok, {_, remaining}}, _) do
    remaining_segment_names =
      remaining
      |> Enum.map(&(&1.__struct__.name(&1)))
      |> Enum.join(", ")

    {:error, "unable to structure full message; #{remaining_segment_names} remaining"}
  end

  defp finalize_structure({:error, _} = everything, _) do
    everything
  end

  @spec segments(Message.t, String.t) :: List
  def segments(message, name) when is_binary(name) do
    segments(message, [name])
  end

  @spec segments(Message.t, List | MapSet) :: List
  def segments(message, names) when not is_binary(names) do
    set = MapSet.new(names)
    Enum.filter(message.segments, fn(%{__struct__: module} = segment) ->
      MapSet.member?(set, module.name(segment))
    end)
  end

  defimpl Enumerable, for: Message do
    def count(%Message{segments: segments}) do
      {:ok, Enum.reduce(segments, 0, &(Segment.count(&1) + &2 + 1))}
    end

    def member?(%Message{segments: segments}, segment_name) do
      {
        :ok,
        Enum.any?(segments, fn(%{__struct__: module} = segment) ->
          module.name(segment) == segment_name || Enum.member?(segment, segment_name)
        end)
      }
    end

    def reduce(_, {:halt, acc}, _fun),                      do: {:halted, acc}
    def reduce(message, {:suspend, acc}, fun),              do: {:suspended, acc, &reduce(message, &1, fun)}
    def reduce(%Message{segments: []}, {:cont, acc}, _fun), do: {:done, acc}

    def reduce(message = %Message{segments: [h | t]}, {:cont, acc}, fun) do
      reduce(%{message | segments: t}, fun.(h, acc), fun)
    end
  end

  defimpl Collectable, for: Message do
    def into(%Message{delimiters: delimiters, segments: segments}) do
      {Enum.reverse(segments), fn
        acc, {:cont, next_segment} -> [next_segment | acc]
        acc,  :done                -> %Message{delimiters: delimiters, segments: Enum.reverse(acc)}
        _,    :halt                -> :ok
      end}
    end
  end

  defimpl String.Chars, for: Message do
    @spec to_string(Message.t) :: String.t
    def to_string(message) do
      message.segments
      |> Stream.map(fn(%{__struct__: module} = segment) ->
        module.to_string(segment, message.delimiters)
      end)
      |> Stream.filter(&(is_binary(&1) and &1 != ""))
      |> Enum.join(message.delimiters.segments)
    end
  end

  # this lets us use to_charlist when sending over TCP/IP
  # doesn't wrap in MLLP though
  defimpl List.Chars, for: Message do
    @spec to_charlist(Message.t) :: binary
    def to_charlist(message) do
      message |> to_string |> String.to_charlist
    end
  end
end
