defmodule Mensendi.Producers.SimpleStreamTest do
  use ExUnit.Case
  alias Mensendi.Producers.SimpleStream
  alias Mensendi.Consumers.Collector
  alias Experimental.GenStage
  doctest SimpleStream

  test "spins up and accepts test" do
    {:ok, simple} = GenStage.start_link(SimpleStream, [])
    {:ok, collector} = GenStage.start_link(Collector, [])

    GenStage.sync_subscribe(collector, to: simple, max_demand: 20)

    SimpleStream.inject(simple, "This is a string")
    assert Collector.retrieve(collector) |> :binary.list_to_bin == "This is a string"

    SimpleStream.inject(simple, "This is a string")
    SimpleStream.inject(simple, "This is a string")
    SimpleStream.inject(simple, "This is a string")
    :timer.sleep(100) # so the injected data can make its way through the system
    assert Collector.retrieve(collector) |> :binary.list_to_bin == "This is a stringThis is a stringThis is a string"
  end
end
