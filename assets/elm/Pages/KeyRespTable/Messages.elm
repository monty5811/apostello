module Pages.KeyRespTable.Messages exposing (..)

import Http


type KeyRespTableMsg
    = ArchiveAllButtonClick String
    | ArchiveAllCheckBoxClick
    | ReceiveArchiveAllResp (Result Http.Error Bool)
