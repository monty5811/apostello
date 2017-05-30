module Pages.FirstRun.Messages exposing (FirstRunMsg(..))

import Http
import Pages.FirstRun.Model exposing (FirstRunResp)


type FirstRunMsg
    = UpdateAdminEmailField String
    | UpdateAdminPass1Field String
    | UpdateAdminPass2Field String
    | UpdateTestEmailToField String
    | UpdateTestEmailBodyField String
    | UpdateTestSmsToField String
    | UpdateTestSmsBodyField String
    | SendTestEmail
    | SendTestSms
    | CreateAdminUser
    | ReceiveCreateAdminUser (Result Http.Error FirstRunResp)
    | ReceiveSendTestSms (Result Http.Error FirstRunResp)
    | ReceiveSendTestEmail (Result Http.Error FirstRunResp)
