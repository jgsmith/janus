defmodule Mensendi.Data.Segment do
  alias Mensendi.Data.{Component, Delimiters, Field, Segment}

  @type t :: %Segment{segment_name: String.t, children: List, fields: List}

  defstruct [segment_name: "", children: [], fields: []]

  @special_segments ["MSH", "BHS", "FHS"]

  @spec to_string(Segment.t, Delimiters.t) :: String.t
  def to_string(segment, delimiters) do
    # each field, followed by each child
    # segments are separated by \r a per HL7 standards
    potential_string = (
      [Enum.map_join(segment.fields,
        delimiters.fields,
        fn(field) ->
          field
          |> Enum.map_join(delimiters.repetitions, &(Field.to_string(&1, delimiters)))
        end
      )]
      ++ Enum.map(segment.children, &(to_string(&1, delimiters)))
    )
    |> Enum.filter(&(is_binary(&1) and &1 != ""))
    |> Enum.join(delimiters.segments)

    if segment.segment_name in @special_segments do
      segment_string_with_delimiters(potential_string, delimiters)
    else
      potential_string
    end
  end

  def segment_string_with_delimiters(string, delimiters) do
    string
    |> String.split(delimiters.fields)
    |> List.replace_at(1, Delimiters.to_string(delimiters))
    |> Enum.join(delimiters.fields)
  end

  def from_string(text, delimiters \\ %Delimiters{}) do
    split_string =
      text
      |> String.trim_trailing(delimiters.fields)
      |> String.split(delimiters.fields)

    {:ok, name} = Enum.fetch(split_string, 0)
    %Segment{
      segment_name: name,
      fields: Enum.map(split_string,
        fn(field) ->
          field
          |> String.split(delimiters.repetitions)
          |> Enum.map(&(Field.from_string(&1, delimiters)))
        end
      )
    }
  end

  def name(%{segment_name: nom} = _segment), do: nom

  def with_child(segment, child) do
    Map.put(segment, :children, segment.children ++ [child])
  end

  def with_children(segment, children) do
    Map.put(segment, :children, segment.children ++ children)
  end

  def to_structured_segment(%{segment_name: name, children: children} = segment) do
    module = Module.concat([Mensendi, Segments, String.to_atom(name)])
    if Code.ensure_loaded?(module) do
      segment
      |> module.from_segment
      |> with_children(
        children
        |> Enum.map(&to_structured_segment/1)
      )
    else
      segment
    end
  end

  # N.B.: The indices start at zero, not 1
  @spec el(Segment.t, {Integer, Integer, Integer}) :: List
  def el(segment, {fieldId, componentId, subcomponentId}) do
    Access.get(segment.fields, [fieldId], [])
    |> Enum.map(fn(field) ->
        field
        |> Field.get_component(componentId)
        |> Component.get_subcomponent(subcomponentId)
      end
    )
    |> Enum.map(fn(subcomponent) ->
        subcomponent.content
      end
    )
  end

  def children(segment) do
    segment.children
  end

  def children(segment, name) when is_binary(name) do
    children(segment, [name])
  end

  @spec children(Segment.t, List | MapSet) :: List
  def children(segment, names) when not is_binary(names) do
    set = MapSet.new(names)
    Enum.filter(segment.children, &(MapSet.member?(set, &1.segment_name)))
  end

  def count(%{children: children} = _segment) do
    Enum.reduce(children, 0, &(1 + count(&1) + &2))
  end

  defimpl Enumerable, for: Segment do
    def count(segment) do
      {:ok, Segment.count(segment)}
    end

    def member?(%Segment{children: children}, segment_name) do
      {:ok, Enum.any?(children, &(&1.segment_name == segment_name || Enum.member?(&1, segment_name)))}
    end

    def reduce(_, {:halt, acc}, _fun),                      do: {:halted, acc}
    def reduce(segment, {:suspend, acc}, fun),              do: {:suspended, acc, &reduce(segment, &1, fun)}
    def reduce(%Segment{children: []}, {:cont, acc}, _fun), do: {:done, acc}

    def reduce(segment = %Segment{children: [h | t]}, {:cont, acc}, fun) do
      reduce(%{segment | children: t}, fun.(h, acc), fun)
    end
  end
end
