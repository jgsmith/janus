defmodule MessageGrammarTest do
  use ExUnit.Case
  doctest MessageGrammar

  test "compile" do
    %MessageGrammar{spec: spec} = MessageGrammar.compile("MSH <PID [PD1] [PV1]>")
    assert spec == [
      "MSH",
      [:with_children,
        "PID",
        [:optional, "PD1"],
        [:optional, "PV1"]
      ]
    ]

    %MessageGrammar{spec: spec} = MessageGrammar.compile("MSH {<PID [PD1] [PV1]>}")
    assert spec == [
      "MSH",
      [:repeatable,
        [:with_children,
          "PID",
          [:optional, "PD1"],
          [:optional, "PV1"]
        ]
      ]
    ]
  end

  test "allowed_segments" do
    allowed =
      "MSH <PID [PD1] {PV1} {[<FOO>]}>"
      |> MessageGrammar.compile
      |> MessageGrammar.allowed_segments

    assert allowed == MapSet.new(["MSH", "PID", "PD1", "PV1", "FOO"])
  end

  test "optional repeating" do
    %MessageGrammar{spec: spec} = MessageGrammar.compile("MSH [{ENV}] [{<FOO>}]")
    assert spec == [
      "MSH",
      [:optional, [:repeatable, "ENV"]],
      [:optional, [:repeatable, [:with_children, "FOO"]]]
    ]
  end
end
