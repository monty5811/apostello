module Pages.Forms.DefaultResponses.Model exposing (DefaultResponsesFormModel, decodeDefaultResponsesFormModel)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)


type alias DefaultResponsesFormModel =
    { keyword_no_match : String
    , default_no_keyword_auto_reply : String
    , default_no_keyword_not_live : String
    , start_reply : String
    , auto_name_request : String
    , name_update_reply : String
    , name_failure_reply : String
    }


decodeDefaultResponsesFormModel : Decode.Decoder DefaultResponsesFormModel
decodeDefaultResponsesFormModel =
    decode DefaultResponsesFormModel
        |> required "keyword_no_match" Decode.string
        |> required "default_no_keyword_auto_reply" Decode.string
        |> required "default_no_keyword_not_live" Decode.string
        |> required "start_reply" Decode.string
        |> required "auto_name_request" Decode.string
        |> required "name_update_reply" Decode.string
        |> required "name_failure_reply" Decode.string
