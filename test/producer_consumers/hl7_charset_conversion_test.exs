defmodule Mensendi.ProducerConsumers.HL7CharsetConversionTest do
  use ExUnit.Case
  alias Mensendi.ProducerConsumers.HL7CharsetConversion
  alias Mensendi.ProducerConsumers.MLLPParser
  alias Mensendi.Producers.SimpleStream
  alias Mensendi.Consumers.Collector
  alias Mensendi.Data.MLLPBuffer
  alias Experimental.GenStage
  doctest MLLPParser

  test "Send message through conversion process" do
    hl7_message_in = ~s"""
    MSH|^~\\&|CERNER||PriorityHealth||||ORU^R01|Q479004375T431430612|P|2.3||||||8859/6~ASCII|
    PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
    PD1||||1234567890^LAST^FIRST^M^^^^^NPI
    OBR|1|341856649^HNAM_ORDERID|\\C2824\\000002006326002362|648088^Basic Metabolic Panel|||20061122151600|||||||||1620^Hooker^Robert^L||||||20061122154733|||F|||||||||||20061122140000
    OBX|1|NM|GLU^Glucose Lvl|59|mg/dL|65-99^65^99|L|||F|||20061122154733
    """ <> << 224 >>

    hl7_message_out = ~s"""
    MSH|^~\\&|CERNER||PriorityHealth||||ORU^R01|Q479004375T431430612|P|2.3||||||8859/6~ASCII|
    PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
    PD1||||1234567890^LAST^FIRST^M^^^^^NPI
    OBR|1|341856649^HNAM_ORDERID|000002006326002362|648088^Basic Metabolic Panel|||20061122151600|||||||||1620^Hooker^Robert^L||||||20061122154733|||F|||||||||||20061122140000
    OBX|1|NM|GLU^Glucose Lvl|59|mg/dL|65-99^65^99|L|||F|||20061122154733
    """ <> << 0xD9, 0x80 >>

    mllp_message =
      hl7_message_in
      |> String.replace("\n", "\r")
      |> MLLPBuffer.wrap_mllp(%MLLPBuffer{})

    {:ok, simple} = GenStage.start_link(SimpleStream, [])
    {:ok, mllp_buffer} = GenStage.start_link(MLLPParser, %MLLPBuffer{})
    {:ok, hl7_conversion} = GenStage.start_link(HL7CharsetConversion, "")
    {:ok, collector} = GenStage.start_link(Collector, [])


    GenStage.sync_subscribe(mllp_buffer, to: simple, max_demand: 10000)
    GenStage.sync_subscribe(hl7_conversion, to: mllp_buffer, max_demand: 10000)
    GenStage.sync_subscribe(collector, to: hl7_conversion, max_demand: 10000)

    SimpleStream.inject(simple, "garbage")
    SimpleStream.inject(simple, mllp_message)
    SimpleStream.inject(simple, "more garbage")
    :timer.sleep(100) # so the injected data can make its way through the system
    [{:ok, message}] = Collector.retrieve(collector)
    assert message |> String.replace("\r", "\n") == hl7_message_out
  end
end
