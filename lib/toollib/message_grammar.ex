defmodule MessageGrammar do
  @type t :: %MessageGrammar{spec: List}

  defstruct [spec: []]

  @spec compile(String.t) :: MessageGrammar.t
  def compile(description) do
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

  def parse(grammar, segments) do
    case segments
         |> drop_unknown_segments(grammar)
         |> gather_segments(grammar.spec)
    do
      {:ok, {gathered, []}}        -> {:ok, {gathered, []}}
      {:ok, {gathered, remaining}} -> {:error, {gathered, remaining}}
      {:error, stuff}              -> {:error, stuff}
    end
  end

  @spec drop_unknown_segments(List, MapSet) :: List
  defp drop_unknown_segments(segments, grammar) do
    allowed = allowed_segments(grammar)
    Enum.filter(segments, &(MapSet.member?(allowed, &1.name)))
  end

  @spec gather_segments([Segment.t], []) :: {:ok, {[], [Segment.t]}}
  defp gather_segments(segments, []) do
    {:ok, {[], segments}}
  end

  @spec gather_segments([Segment.t], [String.t|atom|List]) :: {atom, {[Segment.t], [Segment.t]}}
  defp gather_segments(segments, [h | spec]) when is_list(h) do
    case gather_segments(segments, h) do
      {:ok, {gathered, remaining}} ->
        {status, {more_gathered, truely_remaining}} = gather_segments(remaining, spec)
        {status, {gathered ++ more_gathered, truely_remaining}}
      {:error, stuff} -> {:error, stuff}
    end
  end

  @spec gather_segments([], [String.t|atom|List]) :: {:error, {[], []}}
  defp gather_segments([], [h | _spec]) when is_binary(h) do
    {:error, {[], []}}
  end

  @spec gather_segments([Segment.t], [String.t|atom|List]) :: {atom, {[Segment.t], [Segment.t]}}
  defp gather_segments([candidate_segment | remaining], [h | spec]) when is_binary(h) do
    cond do
      candidate_segment.name == h ->
        {status, {gathered, truely_remaining}} = gather_segments(remaining, spec)
        {status, {[candidate_segment] ++ gathered, truely_remaining}}
      true -> {:error, {[], [candidate_segment] ++ remaining}}
    end
  end

  @spec gather_segments([Segment.t], [String.t|atom|List]) :: {atom, {[Segment.t], [Segment.t]}}
  defp gather_segments(segments, [:with_children | spec]) do
    case gather_segments(segments, spec) do
      {:ok, {[parent | children], remaining}} ->
        {:ok, {[parent |> Segment.with_children(children)], remaining}}
      {:ok, {[], remaining}} -> {:ok, {[], remaining}}
      {:error, stuff} -> {:error, stuff}
    end
  end

  @spec gather_segments([Segment.t], [String.t|atom|List]) :: {atom, {[Segment.t], [Segment.t]}}
  defp gather_segments(segments, [:optional | spec]) do
    case gather_segments(segments, spec) do
      {:ok, stuff} -> {:ok, stuff}
      {:error, _} -> {:ok, {[], segments}}
    end
  end

  @spec gather_segments([Segment.t], [String.t|atom|List]) :: {atom, {[Segment.t], [Segment.t]}}
  defp gather_segments(segments, [:repeatable | spec]) do
    case gather_segments(segments, spec) do
      {:ok, {gathered, remaining}} ->
        {more_gathered, truely_remaining} = gather_repeating_spec(remaining, spec)
        {:ok, {gathered ++ more_gathered, truely_remaining}}
      {:error, stuff} -> {:error, stuff}
    end
  end

  @spec gather_segments([Segment.t], [String.t|atom|List]) :: {:error, {[], [Segment.t]}}
  defp gather_segments(segments, [h | _spec]) when is_atom(h) do
    {:error, {[], segments}}
  end

  @spec gather_repeating_spec([Segment.t], [String.t|atom|List]) :: {atom, {[Segment.t], [Segment.t]}}
  defp gather_repeating_spec(segments, spec) do
    case gather_segments(segments, spec) do
      {:ok, {gathered, remaining}} ->
        {more_gathered, truely_remaining} = gather_repeating_spec(remaining, spec)
        {gathered ++ more_gathered, truely_remaining}
      {:error, _} -> {[], segments}
    end
  end
end
