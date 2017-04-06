module Models.FirstRun
    exposing
        ( FirstRunModel
        , FirstRunResp
        , decodeFirstRunResp
        , initialFirstRunModel
        )

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required, decode)
import Models.FormStatus exposing (FormStatus(NoAction))


type alias FirstRunResp =
    { status : String
    , error : String
    }


decodeFirstRunResp : Decode.Decoder FirstRunResp
decodeFirstRunResp =
    decode FirstRunResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


type alias FirstRunModel =
    { adminEmail : String
    , adminPass1 : String
    , adminPass2 : String
    , adminFormStatus : FormStatus
    , testEmailTo : String
    , testEmailBody : String
    , testEmailFormStatus : FormStatus
    , testSmsTo : String
    , testSmsBody : String
    , testSmsFormStatus : FormStatus
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
