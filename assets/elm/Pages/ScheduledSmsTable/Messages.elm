module Pages.ScheduledSmsTable.Messages exposing (..)

import Http


type ScheduledSmsTableMsg
    = CancelSms Int
    | ReceiveCancelSms (Result Http.Error Bool)
