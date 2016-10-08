defmodule Mensendi.Data.SubComponent do
  # This handles all of the escaping/unescaping of stuff in the string
  # TODO: escape/unescape code points for UTF support
  def encoded(string, delimiters) do
    string
    |> escape_character(delimiters.escapes, "E", delimiters)
    |> escape_character(delimiters.fields, "F", delimiters)
    |> escape_character(delimiters.components, "S", delimiters)
    |> escape_character(delimiters.subcomponents, "T", delimiters)
    |> escape_character(delimiters.repetitions, "R", delimiters)
  end

  def decoded(text, delimiters) do
    text
    |> unescape_character(delimiters.fields, "F", delimiters)
    |> unescape_character(delimiters.components, "S", delimiters)
    |> unescape_character(delimiters.subcomponents, "T", delimiters)
    |> unescape_character(delimiters.repetitions, "R", delimiters)
    |> unescape_character(delimiters.escapes, "E", delimiters)
  end

  defp escape_character(text, char, replacement, delimiters) do
    String.replace(text, char, delimiters.escapes <> replacement <> delimiters.escapes)
  end

  defp unescape_character(text, replacement, char, delimiters) do
    String.replace(text, delimiters.escapes <> char <> delimiters.escapes, replacement)
  end
end
