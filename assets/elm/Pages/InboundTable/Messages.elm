module Pages.InboundTable.Messages exposing (..)

import Data.SmsInbound exposing (SmsInbound)
import Http


type InboundTableMsg
    = ReprocessSms Int
    | ReceiveReprocessSms (Result Http.Error SmsInbound)
