defmodule Mensendi.Utils.MessageGrammarTest do
  alias Mensendi.Utils.MessageGrammar
  use ExUnit.Case
  doctest MessageGrammar

  test "compile" do
    %MessageGrammar{spec: spec} = MessageGrammar.compile("MSH (PID [PD1] [PV1])")
    assert spec == [
      "MSH",
      [:with_children,
        "PID",
        [:optional, "PD1"],
        [:optional, "PV1"]
      ]
    ]

    %MessageGrammar{spec: spec} = MessageGrammar.compile("MSH {(PID [PD1] [PV1])}")
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
      "MSH (PID [PD1] {PV1} {[(FOO)]}) <ZPM|NTE>"
      |> MessageGrammar.compile
      |> MessageGrammar.allowed_segments

    assert allowed == MapSet.new(["MSH", "PID", "PD1", "PV1", "FOO", "ZPM", "NTE"])
  end

  test "optional repeating" do
    %MessageGrammar{spec: spec} = MessageGrammar.compile("MSH [{ENV}] [{(FOO)}] <ZPM|NTE>")
    assert spec == [
      "MSH",
      [:optional, [:repeatable, "ENV"]],
      [:optional, [:repeatable, [:with_children, "FOO"]]],
      [:alternates, "ZPM", "NTE"]
    ]
  end
end
