module Pages.KeyRespTable.Messages exposing (..)

import Data.SmsInbound exposing (SmsInbound)
import Http


type KeyRespTableMsg
    = ToggleInboundSmsArchive Bool Int
    | ToggleInboundSmsDealtWith Bool Int
    | ReceiveToggleInboundSmsArchive (Result Http.Error SmsInbound)
    | ReceiveToggleInboundSmsDealtWith (Result Http.Error SmsInbound)
    | ArchiveAllButtonClick String
    | ArchiveAllCheckBoxClick
    | ReceiveArchiveAllResp (Result Http.Error Bool)
