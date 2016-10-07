defmodule MessageGrammarTest do
  use ExUnit.Case
  doctest MessageGrammar

  test "compile" do
    grammar = MessageGrammar.compile("MSH <PID [PD1] [PV1]>")
    assert grammar == %MessageGrammar{
      spec: ["MSH", [:withChildren, "PID", [:optional, "PD1"], [:optional, "PV1"]]]
    }

    grammar2 = MessageGrammar.compile("MSH {<PID [PD1] [PV1]>}")
    assert grammar2 == %MessageGrammar{
      spec: ["MSH", [:repeatable, [:withChildren, "PID", [:optional, "PD1"], [:optional, "PV1"]]]]
    }
  end

  test "allowed_segments" do
    grammar = MessageGrammar.compile("MSH <PID [PD1] [PV1]>")
    assert MessageGrammar.allowed_segments(grammar) == MapSet.new(["MSH", "PID", "PD1", "PV1"])
  end
end
