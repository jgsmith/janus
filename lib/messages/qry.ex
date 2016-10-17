defmodule Mensendi.Messages.QRY do
  use Mensendi.DSL.Message

  message_type :QRY

########################################

  event :A19, :query
  title "Patient Query"

  message_structure ~s"""
  ( MSH [{ SFT }] )
  ( QRD [ QRF ] )
  """

  ack_type :ADR

  ack_structure ~s"""
  ( MSH [{ SFT }] )
  ( MSA [ ERR ]
        [ QAK ] QRD [ QRF ]
  )
  {(
    [ EVN ]
    PID [ PD1 ] [{<ROL|NK1>}]
    PV1 [ PV2 ] [{<ROL|DB1|OBX|AL1|DG1>}]
        [ DRG ]
        [{( PR1 [{ ROL }] )}]
        [{ GT1 }]
        [{( IN1 [ IN2 ] [{<IN3|ROL>}])}]
    [ ACC ] [ UB1 ] [ UB2 ]
  )}
  [ DSC ]
  """

########################################

end
