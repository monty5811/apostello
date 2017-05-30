module Pages.FirstRun.Model exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)


type alias FirstRunResp =
    { status : String
    , error : String
    }


type FirstRunFormStatus
    = NoAction
    | InProgress
    | Success
    | Failed String


decodeFirstRunResp : Decode.Decoder FirstRunResp
decodeFirstRunResp =
    decode FirstRunResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


type alias FirstRunModel =
    { adminEmail : String
    , adminPass1 : String
    , adminPass2 : String
    , adminFormStatus : FirstRunFormStatus
    , testEmailTo : String
    , testEmailBody : String
    , testEmailFormStatus : FirstRunFormStatus
    , testSmsTo : String
    , testSmsBody : String
    , testSmsFormStatus : FirstRunFormStatus
    }


initialFirstRunModel : FirstRunModel
initialFirstRunModel =
    { adminEmail = ""
    , adminPass1 = ""
    , adminPass2 = ""
    , adminFormStatus = NoAction
    , testEmailTo = ""
    , testEmailBody = ""
    , testEmailFormStatus = NoAction
    , testSmsTo = ""
    , testSmsBody = ""
    , testSmsFormStatus = NoAction
    }
