module Pages.ElvantoImport.Messages
    exposing
        ( ElvantoMsg
            ( FetchGroups
            , PullGroups
            , ReceiveButtonResp
            )
        )

import Http


type ElvantoMsg
    = PullGroups
    | FetchGroups
    | ReceiveButtonResp (Result Http.Error Bool)
