defmodule Mensendi.ProducerConsumers.MLLPParserBench do
  use Benchfella
  alias Mensendi.ProducerConsumers.MLLPParser
  alias Mensendi.Producers.SimpleStream
  alias Mensendi.Consumers.Collector
  alias Mensendi.Data.MLLPBuffer
  alias Experimental.GenStage

  before_each_bench _ do
    {:ok, simple} = GenStage.start_link(SimpleStream, [])
    {:ok, mllp_buffer} = GenStage.start_link(MLLPParser, %MLLPBuffer{})
    {:ok, collector} = GenStage.start_link(Collector, [])

    GenStage.sync_subscribe(mllp_buffer, to: simple, max_demand: 10000)
    GenStage.sync_subscribe(collector, to: mllp_buffer, max_demand: 10000)

    message = << 0x0B >> <> ~s"""
    MSH|^~\\&|CERNER||PriorityHealth||||ORU^R01|Q479004375T431430612|P|2.3
    PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
    PD1||||1234567890^LAST^FIRST^M^^^^^NPI
    OBR|1|341856649^HNAM_ORDERID|000002006326002362|648088^Basic Metabolic Panel|||20061122151600|||||||||1620^Hooker^Robert^L||||||20061122154733|||F|||||||||||20061122140000
    OBX|1|NM|GLU^Glucose Lvl|59|mg/dL|65-99^65^99|L|||F|||20061122154733
    """ <> << 0x1C, 0x0D >>

    {:ok, {simple, mllp_buffer, collector, message}}
  end

  after_each_bench pid do
  end

  bench "injecting and retrieving single messages" do
    {simple, mllp_buffer, collector, message} = bench_context

    SimpleStream.inject(simple, message)
    :timer.sleep(1)
    Collector.retrieve(collector, 1)
  end

  bench "injecting and retrieving ten messages" do
    {simple, mllp_buffer, collector, message} = bench_context

    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)
    SimpleStream.inject(simple, message)

    :timer.sleep(5)

    Collector.retrieve(collector, 10)
  end

  bench "injecting messages" do
    {simple, mllp_buffer, collector, message} = bench_context

    SimpleStream.inject(simple, message)
  end
end
