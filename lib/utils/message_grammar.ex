defmodule Mensendi.Utils.MessageGrammar do
  alias Mensendi.Data.Segment
  alias __MODULE__
  use OkJose

  @type t :: %MessageGrammar{spec: List}

  defstruct [spec: []]

  @spec compile(String.t|MessageGrammar.t) :: MessageGrammar.t
  def compile(description) when is_binary(description) do
    {:ok, tokens, _} = description |> to_char_list |> :sequence_grammar_lexer.string
    {:ok, list}      = :sequence_grammar_parser.parse(tokens)
    %MessageGrammar{spec: list}
  end

  @spec allowed_segments(MessageGrammar.t) :: MapSet.type
  def allowed_segments(grammar) do
    grammar.spec
    |> allowed_segments_given_list
    |> MapSet.new
  end

  defp allowed_segments_given_list(list) when is_list(list) do
    list |> Enum.flat_map(&allowed_segments_given_list/1)
  end

  defp allowed_segments_given_list(binary) when is_binary(binary) do
    [binary]
  end

  defp allowed_segments_given_list(atom) when is_atom(atom) do
    []
  end

  def parse(%{spec: spec} = grammar, segments) do
    case segments
         |> drop_unknown_segments(grammar)
         |> gather_segments(spec)
    do
      {:ok, {gathered, []}} -> {:ok, {gathered, []}}
      {:ok, {_, _}}         -> {:error, "segments remaining after structuring"}
      {:error, stuff}       -> {:error, stuff}
    end
  end

  def uncompile(%{spec: spec} = _grammar) do
    do_uncompile(spec, "", 0)
  end

  defp do_uncompile([], "", _), do: ""
  defp do_uncompile([], acc, _), do: acc

  defp do_uncompile(h, "", _) when is_binary(h), do: h
  defp do_uncompile(h, acc, idx) when is_binary(h), do: acc <> "\n" <> prefix_ws(idx) <> h

  defp do_uncompile([h | rest], "", idx) when is_binary(h), do: do_uncompile(rest, h, idx)
  defp do_uncompile([h | rest], acc, idx) when is_binary(h), do: do_uncompile(rest, acc <> " " <> h, idx)

  defp do_uncompile([h | rest], acc, idx) when is_list(h), do: do_uncompile(rest, do_uncompile(h, acc, idx), idx)

  defp do_uncompile([:optional | rest], "", idx), do: "[" <> do_uncompile(rest, "", idx) <> "]"
  defp do_uncompile([:optional | rest], acc, idx), do: acc <> " [" <> do_uncompile(rest, "", idx) <> "]"

  defp do_uncompile([:repeatable | rest], "", idx), do: "{" <> do_uncompile(rest, "", idx) <> "}"
  defp do_uncompile([:repeatable | rest], acc, idx), do: acc <> " {" <> do_uncompile(rest, "", idx) <> "}"

  defp do_uncompile([:with_children | rest], "", idx), do: "(\n" <> do_uncompile(rest, "", idx + 1) <> "\n)\n"
  defp do_uncompile([:with_children | rest], acc, idx), do: acc <> "\n(\n" <> do_uncompile(rest, "", idx) <> "\n)\n"

  defp do_uncompile([:alternates | rest], "", idx), do: "<" <> do_uncompile_alternates(rest, "", idx) <> ">"
  defp do_uncompile([:alternates | rest], acc, idx), do: acc <> " <" <> do_uncompile_alternates(rest, "", idx) <> ">"

  defp do_uncompile_alternates([h | rest], "", idx), do: do_uncompile_alternates(rest, do_uncompile(h, "", idx), idx)
  defp do_uncompile_alternates([h | rest], acc, idx), do: do_uncompile_alternates(rest, acc <> "|" <> do_uncompile(h, "", idx), idx)

  defp do_uncompile_alternates([], acc, idx), do: acc

  defp prefix_ws(idx), do: List.duplicate("  ", idx) |> Enum.join

  @spec drop_unknown_segments(List, MapSet) :: List
  defp drop_unknown_segments(segments, grammar) do
    allowed = allowed_segments(grammar)
    {[], Enum.filter(segments, &(MapSet.member?(allowed, &1.__struct__.name(&1))))}
  end

  @spec gather_segments({[Segment.t], [Segment.t]}, [String.t|atom|List]) :: {:ok, {[Segment.t], [Segment.t]}}
                                                                           | {:error, String.t}
  defp gather_segments(segments, spec)

  defp gather_segments({found, remaining}, []) do
    {:ok, {found, remaining}}
  end

  defp gather_segments({found, remaining}, [h | spec]) when is_list(h) do
    case gather_segments({found, remaining}, h) do
      {:ok, {gathered, truely_remaining}} -> gather_segments({gathered, truely_remaining}, spec)
      anything                            -> anything
    end
  end

  defp gather_segments({_, []}, [h | _spec]) when is_binary(h) do
    {:error, "expecting another segment (#{h}) but no segments remain"}
  end

  defp gather_segments({gathered, [candidate_segment | remaining]}, [h | spec]) when is_binary(h) do
    if candidate_segment.segment_name == h do
      gather_segments({gathered ++ [candidate_segment], remaining}, spec)
    else
      {:error, "missing expected segment (#{h})"}
    end
  end

  defp gather_segments({gathered, remaining}, [:with_children | spec]) do
    case gather_segments({[], remaining}, spec) do
      {:ok, {[parent | children], truely_remaining}} ->
        {:ok, {gathered ++ [parent |> Segment.with_children(children)], truely_remaining}}
      anything -> anything
    end
  end

  defp gather_segments({_,_} = segments, [:optional | spec]) do
    case gather_segments(segments, spec) do
      {:error, _} -> {:ok, segments}
      anything -> anything
    end
  end

  defp gather_segments({_,_} = segments, [:repeatable | spec]) do
    case gather_segments(segments, spec) do
      {:ok, {gathered, remaining}} ->
        gather_repeating_spec({gathered, remaining}, spec)
      anything -> anything
    end
  end

  defp gather_segments({_,_} = segments, [:alternates | spec]), do: gather_alternate_segments(segments, spec)

  defp gather_segments({_,_}, [h | _]) when is_atom(h) do
    {:error, "Unknown action (#{h})"}
  end

  @spec gather_alternate_segments({[Segment.t], [Segment.t]}, [String.t|List]) :: {:ok, {[Segment.t], [Segment.t]}}
                                                                                | {:error, String.t}
  defp gather_alternate_segments(_, []), do: {:error, "No alternatives match"}
  defp gather_alternate_segments({_, _} = segments, [only_option]), do: gather_segments(segments, [only_option])

  defp gather_alternate_segments({_, _} = segments, [ trial | rest ]) do
    case gather_segments(segments, [trial]) do
      {:ok, stuff} -> {:ok, stuff}
      _            -> gather_alternate_segments(segments, rest)
    end
  end

  @spec gather_repeating_spec({[Segment.t], [Segment.t]}, [String.t|atom|List]) :: {:ok, {[Segment.t], [Segment.t]}}
  defp gather_repeating_spec(segments, spec) do
    case gather_segments(segments, spec) do
      {:ok, result} -> gather_repeating_spec(result, spec)
      {:error, _} -> {:ok, segments}
    end
  end
end
