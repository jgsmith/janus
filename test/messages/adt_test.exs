defmodule Mensendi.Messages.ADTTest do
  alias Mensendi.Messages.ADT
  alias Mensendi.Data.Message
  use ExUnit.Case
  use OkJose
  doctest ADT

  test "Selects correct event" do
    message = ~s"""
    MSH|^~\\&|CERNER||PriorityHealth||||ADT^A02|Q479004375T431430612|P|2.3
    EVN|
    PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
    PV1|
    """ |> String.replace("\n", "\r")

    event =
      {:ok, message}
      |> Message.from_string
      |> ADT.find_message_event
      |> ok!

    assert event.event == "A02"
  end

  test "constructs named segment data objects" do
    message = ~s"""
    MSH|^~\\&|CERNER||PriorityHealth||||ADT^A02|Q479004375T431430612|P|2.3
    EVN|
    PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
    PV1|
    """ |> String.replace("\n", "\r")

    structured_message =
      {:ok, message}
      |> Message.from_string
      |> ADT.structure_message
      |> ok!

    assert Enum.count(structured_message) == 4

    assert Enum.count(Message.segments(structured_message, "MSH")) == 1
    assert Enum.count(Message.segments(structured_message, "EVN")) == 1
    assert Enum.count(Message.segments(structured_message, "PID")) == 1
    assert Enum.count(Message.segments(structured_message, "PV1")) == 0
  end

  test "finds the missing EVN segment" do
    message = ~s"""
    MSH|^~\\&|CERNER||PriorityHealth||||ADT^A02|Q479004375T431430612|P|2.3
    PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
    PV1|
    """ |> String.replace("\n", "\r")

    {:error, error_message} =
      {:ok, message}
      |> Message.from_string
      |> ok!
      |> ADT.structure_message
    assert error_message == "missing expected segment (EVN)"
  end
end
