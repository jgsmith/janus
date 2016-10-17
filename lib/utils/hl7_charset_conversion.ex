defmodule Mensendi.Utils.HL7CharsetConversion do
  require Codepagex
  
  # alias __MODULE__
  @moduledoc """
  Provides the conversion of HL7 messages to UTF-8.

  Conversion is complicated because HL7 messages can change their encoding part-way through a message.
  """

  def convert_to_utf8(binary, default_charset) do
    binary
    |> detect_charsets
    |> do_convert_to_utf8(binary, default_charset)
  end

  defp detect_charsets(binary) do
    with << "MSH", pipe :: bytes-size(1), _ :: bytes-size(1), tilde :: bytes-size(1), _ :: binary >> <- binary do
      bits = :binary.split(binary, pipe, [:global])
      # we need MSH.18 to tell us which character set to use - we assume 7-bit ASCII at least that far
      :binary.split(Enum.at(bits, 17, ""), tilde, [:global])
    else
      _ -> ""
    end
  end

  defp collect_by_collation(binary, {parts, current_collation, acc} = state, {default_collation, valid_encodings, boundaries, escape} = config) do
    case binary do
      << ^escape :: bytes-size(1), "C", collation_code :: bytes-size(4), ^escape :: bytes-size(1), rest :: binary >> ->
        computed_collation = collation_for_hl7_code("C" <> collation_code)
        if MapSet.member?(valid_encodings, computed_collation) do
          if computed_collation == current_collation do
            collect_by_collation(rest, state, config)
          else
            collect_by_collation(rest, {[{current_collation, acc} | parts], computed_collation, ""}, config)
          end
        else
          collect_by_collation(rest, {[{current_collation, acc} | parts], invalid_collation_code("C" <> collation_code), ""}, config)
        end

      << ^escape :: bytes-size(1), "D", collation_code :: bytes-size(4), ^escape :: bytes-size(1), rest :: binary >> ->
        collect_by_collation(rest, {[{current_collation, acc} | parts], invalid_collation_code("D" <> collation_code), ""}, config)

      << ^escape :: bytes-size(1), "D", collation_code :: bytes-size(6), ^escape :: bytes-size(1), rest :: binary >> ->
        collect_by_collation(rest, {[{current_collation, acc} | parts], invalid_collation_code("D" <> collation_code), ""}, config)

      << a_byte :: bytes-size(1), rest :: binary >> ->
        if MapSet.member?(boundaries, a_byte |> :binary.bin_to_list |> List.first) do
          if current_collation == default_collation do
            collect_by_collation(rest, {parts, default_collation, acc <> a_byte}, config)
          else
            collect_by_collation(rest, {[{current_collation, acc} | parts], default_collation, a_byte}, config)
          end
        else
          collect_by_collation(rest, {parts, current_collation, acc <> a_byte}, config)
        end

      << >> -> Enum.reverse([{current_collation, acc} | parts])
    end
  end

  defp error?({:error, _}), do: true
  defp error?({:ok, _}), do: false

  defp extract_second({_, string}), do: string

  defp do_convert_to_utf8(encodings, binary, default) when is_list(encodings) and not is_binary(encodings) do
    boundaries =
      (:binary.part(binary, 3, 3) <> :binary.part(binary, 7, 1) <> "\r")
      |> :binary.bin_to_list
      |> MapSet.new
    escape = :binary.part(binary, 6, 1)

    results = binary
    |> collect_by_collation({[], List.first(encodings), ""}, {List.first(encodings), MapSet.new(encodings), boundaries, escape})
    |> Enum.map(fn {collation, bytes} -> do_convert_to_utf8(collation, bytes, default) end)

    if Enum.any?(results, &error?/1) do
      {
        :error,
        results
        |> Enum.filter(&error?/1)
        |> Enum.map(&extract_second/1)
        |> Enum.sort
        |> Enum.uniq
        |> Enum.join("; ")
      }
    else
      {
        :ok,
        results
        |> Enum.map(&extract_second/1)
        |> Enum.join
      }
    end
  end


  defp do_convert_to_utf8(_, "", _), do: ""
  defp do_convert_to_utf8("", binary, default),        do: do_convert_to_utf8(default, binary, "")
  # (7-bit) ASCII is already a subset of UTF-8
  defp do_convert_to_utf8("ASCII", binary, _),         do: {:ok, binary}
  # UTF-8 is already UTF-8
  defp do_convert_to_utf8("UNICODE UTF-8", binary, _), do: {:ok, binary}

  defp do_convert_to_utf8("8859/1", binary, _),        do: Codepagex.to_string(binary, :iso_8859_1)
  defp do_convert_to_utf8("8859/2", binary, _),        do: Codepagex.to_string(binary, :iso_8859_2)
  defp do_convert_to_utf8("8859/3", binary, _),        do: Codepagex.to_string(binary, :iso_8859_3)
  defp do_convert_to_utf8("8859/4", binary, _),        do: Codepagex.to_string(binary, :iso_8859_4)
  defp do_convert_to_utf8("8859/5", binary, _),        do: Codepagex.to_string(binary, :iso_8859_5)
  defp do_convert_to_utf8("8859/6", binary, _),        do: Codepagex.to_string(binary, :iso_8859_6)
  defp do_convert_to_utf8("8859/7", binary, _),        do: Codepagex.to_string(binary, :iso_8859_7)
  defp do_convert_to_utf8("8859/8", binary, _),        do: Codepagex.to_string(binary, :iso_8859_8)
  defp do_convert_to_utf8("8859/9", binary, _),        do: Codepagex.to_string(binary, :iso_8859_9)

  defp do_convert_to_utf8(encoding, binary, _) do
    {:error, binary, "Encoding \"#{encoding}\" is not supported"}
  end

  defp collation_for_hl7_code("C2824"), do: "ASCII"
  defp collation_for_hl7_code("C2D41"), do: "8859/1"
  defp collation_for_hl7_code(foo), do: invalid_collation_code(foo) # will result in an unknown encoding later

  defp invalid_collation_code(foo), do: "\\#{foo}\\"
end
