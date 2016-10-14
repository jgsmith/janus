defmodule Mensendi.Data.MLLPBuffer do
  alias __MODULE__
  @type t :: %MLLPBuffer{buffer: binary, message_start: binary, message_end: binary}

  @default_message_start <<0x0B>>
  @default_message_end   <<0x1C, 0x0D>>

  defstruct [buffer: << >>, message_start: @default_message_start, message_end: @default_message_end]

  @spec with_message_start(MLLPBuffer.t, binary) :: MLLPBuffer.t
  def with_message_start(mllp_buffer, string) do
    %{mllp_buffer | message_start: string}
  end

  @spec with_message_end(MLLPBuffer.t, binary) :: MLLPBuffer.t
  def with_message_end(mllp_buffer, string) do
    %{mllp_buffer | message_end: string}
  end

  @doc """
  Retrieves the next message in the buffer.

  ## Example

      iex> buffer = MLLPBuffer.add_data(%MLLPBuffer{}, << "foo", 0x0B, "MSH|", 0x1C, 0x0D >>)
      ...> {:ok, message, _remainder} = MLLPBuffer.next_message(buffer)
      ...> message
      "MSH|"
  """
  @spec next_message(MLLPBuffer.t) :: { :ok | :none, Binary, MLLPBuffer.t }
  def next_message(%MLLPBuffer{buffer: binary, message_start: message_start, message_end: message_end} = mllp_buffer) do
    with {message, rest} <- binary |> clean_initial_junk(message_start) |> get_initial_message(message_start, message_end) do
      {:ok, message, %{mllp_buffer | buffer: rest}}
    else
      _ -> {:none, << >>, mllp_buffer}
    end
  end

  def wrap_mllp(binary, %MLLPBuffer{message_start: message_start, message_end: message_end} = _mllp_buffer) do
    message_start <> binary <> message_end
  end

  @doc """
  Removes anything at the beginning of the buffer until the start of a message.

  ## Example

  With nothing in the buffer, nothing is returned.
      iex(1)> MLLPBuffer.clean_initial_junk(<< >>, <<"!">>)
      << >>

  With something in the buffer, but no start of message in the buffer.
      iex(2)> MLLPBuffer.clean_initial_junk(<<"This is fun">>, <<"!">>)
      << >>

  With something in the buffer and a start of message in the buffer.
      iex(3)> MLLPBuffer.clean_initial_junk(<<"This is fun! and cool.">>, <<"!">>)
      "! and cool."

  With something in the buffer and the start of message at the end.
      iex(4)> MLLPBuffer.clean_initial_junk(<<"This is fun!">>, <<"!">>)
      "!"

  With start of message at the beginning.
      iex(5)> MLLPBuffer.clean_initial_junk(<<"! and cool.">>, <<"!">>)
      "! and cool."

  With a multi-byte start of message.
      iex(6)> MLLPBuffer.clean_initial_junk(<<"This is fun:: but interesting">>, <<"::">>)
      ":: but interesting"

  With part of a multi-byte start at the end.
      iex(7)> MLLPBuffer.clean_initial_junk(<<"This is fun:">>, <<"::">>)
      ":"
  """
  @spec clean_initial_junk(binary, binary) :: binary
  def clean_initial_junk(binary, << >>), do: binary

  def clean_initial_junk(binary, message_start) when byte_size(binary) < byte_size(message_start) do
    binary
  end

  def clean_initial_junk(binary, message_start) do
    message_start_length = byte_size(message_start)
    case binary do
      << ^message_start :: bytes-size(message_start_length), _ :: binary >> -> binary
      << _, rest :: binary >> -> clean_initial_junk(rest, message_start)
    end
  end

  defp get_initial_message(<< >>, _, _), do: :none

  defp get_initial_message(mllp_buffer, message_start, message_end) when byte_size(mllp_buffer) >= (byte_size(message_start) + byte_size(message_end)) do
    message_start_length = byte_size(message_start)
    with << ^message_start :: bytes-size(message_start_length), rest :: binary >> <- mllp_buffer do
      get_bytes_until_eom(rest, message_end)
    else
      _ -> :none
    end
  end

  defp get_initial_message(_, _, _), do: :none

  defp get_bytes_until_eom(binary, message_end, acc \\ << >> )

  defp get_bytes_until_eom(<< >>, _, << >>), do: :none

  defp get_bytes_until_eom(<< >>, _, acc), do: acc

  defp get_bytes_until_eom(binary, message_end, acc) when byte_size(binary) >= byte_size(message_end) do
    message_end_length = byte_size(message_end)
    case binary do
      << ^message_end :: bytes-size(message_end_length), rest :: binary >> -> { acc, rest }
      << a_byte :: bytes-size(1), rest :: binary >> -> get_bytes_until_eom(rest, message_end, acc <> a_byte)
      _ -> :none
    end
  end

  defp get_bytes_until_eom(_, _, _), do: :none

  @doc """
  Appends the given binary data to the end of the buffer.

  ## Example

      iex> mllp_buffer = %MLLPBuffer{buffer: "--"}
      ...> MLLPBuffer.add_data(mllp_buffer, <<"This is the ", 0x0B, " time for the brown fox">>)
      %MLLPBuffer{buffer: <<0x0B, " time for the brown fox">>}
  """
  @spec add_data(MLLPBuffer.t, binary) :: MLLPBuffer.t
  def add_data(%MLLPBuffer{buffer: buffer, message_start: message_start} = mllp_buffer, data) do
    %{mllp_buffer | buffer: clean_initial_junk(buffer <> data, message_start)}
  end
end
