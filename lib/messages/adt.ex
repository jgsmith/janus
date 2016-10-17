defmodule Mensendi.Messages.ADT do
  use Mensendi.DSL.Message

  message_type :ADT

########################################

  event :A01
  title "Admin/Visit Notification"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [{ GT1 }]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ UB1 ] [ UB2 ] [ PDA ]
  )
  """

  ack_structure ~s"""
  ( MSH [{ SFT }] )
  ( MSA [{ ERR }] )
  """

########################################

  event :A02
  title "Transfer a patient"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{ ROL }]
    PV1 [ PV2 ] [{<ROL|DB1>}] [ PDA ]
  )
  """

########################################

  event :A03
  title "Discharge/End Visit"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [{<OBX|GT1>}]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ PDA ]
  )
  """

########################################

  event :A04
  title "Register a Patient"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ] [{( PR1 [{ ROL }] )}]
        [{ GT1 }]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ UB1 ] [ UB2 ] [ PDA ]
  )
  """

########################################

  event :A05
  title "Pre-Admit a Patient"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ UB1 ] [ UB2 ]
  )
  """

########################################

  event :A06
  title "Change an Outpatient to an Inpatient"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{ ROL }]
        [ MRG ] [{ NK1 }]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [ GT1 ]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ UB1 ] [ UB2 ]
  )
  """

########################################

  event :A07
  title "Change an Inpatient to an Outpatient"

  # message structure is the same as for A06

########################################

  event :A08
  title "Update Patient Information"

  # message structure is the same as for A01
  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [{ GT1 }]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ UB1 ] [ UB2 ] [ PDA ]
  )
  """

########################################

  event :A09
  title "Patient Departing - Tracking"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX|DG1>}]
  )
  """

########################################

  event :A10
  title "Patient Arriving - Tracking"

  # message structure is the same as for A09

########################################

  event :A11
  title "Cancel Admit/Visit Notification"

  # message structure is the same as for A09

########################################

  event :A12
  title "Cancel Transfer"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX>}]
        [ DG1 ]
  )
  """

########################################

  event :A13
  title "Cancel Discharge/End Visit"

  # message structure is the same as A01
  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [{ GT1 }]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ UB1 ] [ UB2 ] [ PDA ]
  )
  """

########################################

  event :A14
  title "Pending Admit"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [{ GT1 }]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
        [ ACC ] [ UB1 ] [ UB2 ]
  )
  """

########################################

  event :A15
  title "Pending Transfer"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{ROL}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|DG1>}]
  )
  """

########################################

  event :A16
  title "Pending Discharge"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
    [ DRG ]
    [{( PR1 [{ ROL }] )}]
    [{ GT1 }]
    [{ IN1 [ IN2 ] [{<IN3|ROL>}] }]
    [ ACC ]
  )
  """

########################################

  event :A17
  title "Swap Patients"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX>}]
  )
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX>}]
  )
  """

########################################

  event :A18
  title "Merge Patient Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] )
  MRG
  PV1
  """

########################################

  event :A20
  title "Bed Status Update"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  NPU
  """

########################################

  event :A21
  title "Patient Goes on a Leave of Absence"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX>}]
  )

  """

########################################

  event :A22
  title "Patient Returns From a Leave of Absence"

  # message structure is the same as for A21

########################################

  event :A23
  title "Delete a Patient Record"

  # message structure is the same as for A21

########################################

  event :A24
  title "Link Patient Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [ PV1 ] [{ DB1 }] )
  ( PID [ PD1 ] [ PV1 ] [{ DB1 }] )
  """

########################################

  event :A25
  title "Cancel Pending Discharge"
  # counters A16

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX>}]
  )
  """

########################################

  event :A26
  title "Cancel Pending Transfer"
  # counters A15

  # message structure is the same as for A25

########################################

  event :A27
  title "Cancel Pending Admit"
  # counters A14

  # message structure is the same as for A25

########################################

  event :A28
  title "Add Person or Patient Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
    [{( PR1 [{ ROL }] )}]
    [{ GT1 }]
    [{( IN1 [ IN2 ] [{<IN3|ROL>}] )}]
    [ ACC ] [ UB1 ] [ UB2 ]
  )
  """

########################################

  event :A29
  title "Delete Person Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX>}]
  )
  """

########################################

  event :A30
  title "Merge Person Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  (PID [PD1])
  MRG
  """

########################################

  event :A31
  title "Update Person Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
    [{( PR1 { ROL } )}]
    [{ GT1 }]
    [{ IN1 [ IN2 ] [{<IN3|ROL>}] }]
    [ ACC ] [ UB1 ] [ UB2 ]
  )
  """

########################################

  event :A32
  title "Cancel Patient Arriving - Tracking"
  # cancels A10

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX>}]
  )
  """

########################################

  event :A33
  title "Cancel Patient Departing - Tracking"

  # message structure is the same as for A32

########################################

  event :A34
  title "Merge Patient Information - Patient ID Only"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  PID [ PD1 ]
  MRG
  """

########################################

  event :A35
  title "Merge Patient Information - Account Number Only"

  # message structure is the same as for A34

########################################

  event :A36
  title "Merge Patient Information - Patient ID & Account Number"

  # message structure is the same as for A34

########################################

  event :A37
  title "Unlink Patient Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
        [ PV1 ] [{ DB1 }]
  )
  ( PID [ PD1 ]
        [ PV1 ] [{ DB1 }]
  )
  """

########################################

  event :A38
  title "Cancel Pre-Admit"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ] [{<DB1|OBX|DG1>}]
        [ DRG ]
  )
  """

########################################

  event :A39
  title "Merge Person - Patient ID"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  {(
    PID [ PD1 ]
    MRG
    [ PV1 ]
  )}
  """

########################################

  event :A40
  title "Merge Patient - Patient Identifier List"

  # message structure is the same as for A39

########################################

  event :A41
  title "Merge Account - Patient Account Number"

  # message structure is the same as for A39

########################################

  event :A42
  title "Merge Visit - Visit Number"

  # message structure is the same as for A39

########################################

  event :A43
  title "Move Patient Information - Patient Identifier List"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  {(
    PID [ PD1 ]
    MRG
  )}
  """

########################################

  event :A44
  title "Move Account Information - Patient Account Number"

  # message structure is the same a for A43

########################################

  event :A45
  title "Move Visit Information - Visit Number"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    { MRG PV1 }
  )
  """

########################################

  event :A46
  title "Change Patient ID"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  PID [ PD1 ]
  MRG
  """

########################################

  event :A47
  title "Change Patient Identifier List"

  # message structure is the same as for A46

########################################

  event :A48
  title "Change Alternate Patient ID"

  # message structure is the same as for A46

########################################

  event :A49
  title "Change Patient Account Number"

  # message structure is the same as for A46

########################################

  event :A50
  title "Change Visit Number"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  PID [ PD1 ]
  MRG
  PV1
  """

########################################

  event :A51
  title "Change Alternate Visit ID"

  # message structure is the same as for A50

########################################

  event :A52
  title "Cancel Leave of Absence for a Patient"
  # counters A21

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ]
  )
  """

########################################

  event :A53
  title "Cancel Patient Returns from a Leave of Absence"
  # counters A22

  # message structure is the same as for A52

########################################

  event :A54
  title "Change Attending Doctor"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ] [{ ROL }]
    PV1 [ PV2 ] [{ ROL }]
  )
  """

########################################

  event :A55
  title "Cancel Change Attending Doctor"
  # counters A54

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    PV1 [ PV2 ]
  )
  """

########################################

  event :A60
  title "Update Adverse Reaction Information"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PV1 ] [ PV2 ] [{ IAM }] )
  """

########################################

  event :A61
  title "Change Consulting Doctor"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  EVN
  ( PID [ PD1 ]
    (PV1 [{ ROL }]) [ PV2 ]
  )
  """

########################################

  event :A62
  title "Cancel Change Consulting Doctor"
  # counters A61

  # message structure is the same as for A61

########################################

end
