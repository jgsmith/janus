defmodule ADTMessage do
  use MessageDSL

  message_type :ADT

########################################

  event        :A01
  description "Admin/Visit Notification"

  message_structure ~s"""
  < MSH
    [{ SFT }]
  >
  EVN
  < PID
    [  PD1 ]
    [{ ROL }]
    [{ NK1 }]
       PV1
    [  PV2  ]
    [{ ROL }]
    [{ DB1 }]
    [{ OBX }]
    [{ AL1 }]
    [{ DG1 }]
    [  DRG  ]
    [{< PR1
        [{ ROL }]
    >}]
    [{ GT1 }]
    [{< IN1
        [  IN2  ]
        [{ IN3 }]
        [{ ROL }]
    >}]
    [  ACC  ]
    [  UB1  ]
    [  UB2  ]
    [  PDA  ]
  >
  """

  ack_structure ~s"""
  < MSH
    [{ SFT }]
  >
  < MSA
    [{ ERR }]
  >
  """

########################################

  event :A02
  description "Transfer a patient"

  message_structure ~s"""
  < MSH
    [{ SFT }]
  >
  EVN
  < PID
    [  PD1 ]
    [{ ROL }]
       PV1
    [  PV2  ]
    [{ ROL }]
    [{ DB1 }]
    [  PDA  ]
  >
  """

########################################

  event :A03
  description "Discharge/End Visit"

  message_structure ~s"""
  < MSH
    [{ SFT }]
  >
  EVN
  < PID
    [  PD1 ]
    [{ ROL }]
    [{ NK1 }]
       PV1
    [  PV2  ]
    [{ ROL }]
    [{ DB1 }]
    [{ AL1 }]
    [{ DG1 }]
    [  DRG  ]
    [{< PR1
        [{ ROL }]
    >}]
    [{ OBX }]
    [{ GT1 }]
    [{< IN1
        [  IN2  ]
        [{ IN3 }]
        [{ ROL }]
    >}]
    [  ACC  ]
    [  PDA  ]
  >
  """

########################################

  event :A04
  description "Register a Patient"

  message_structure ~s"""
  < MSH
    [{ SFT }]
  >
  EVN
  < PID
    [  PD1 ]
    [{ ROL }]
    [{ NK1 }]
       PV1
    [  PV2  ]
    [{ ROL }]
    [{ DB1 }]
    [{ OBX }]
    [{ AL1 }]
    [{ DG1 }]
    [  DRG  ]
    [{< PR1
        [{ ROL }]
    >}]
    [{ GT1 }]
    [{< IN1
        [  IN2  ]
        [{ IN3 }]
        [{ ROL }]
    >}]
    [  ACC  ]
    [  UB1  ]
    [  UB2  ]
    [  PDA  ]
  >
  """

########################################

end
