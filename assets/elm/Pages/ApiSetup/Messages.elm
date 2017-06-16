module Pages.ApiSetup.Messages exposing (ApiSetupMsg(..))

import Http


type ApiSetupMsg
    = Get
    | Generate
    | Delete
    | ReceiveApiKey (Result Http.Error String)
