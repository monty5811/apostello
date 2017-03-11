module Models.Remote exposing (..)

import Json.Decode as Decode


type alias RawResponse =
    { body : String
    , next : Maybe String
    }


type RemoteDataType
    = IncomingSms
    | OutgoingSms
    | Contacts
    | Groups
    | Keywords
    | ScheduledSms
    | ElvantoGroups
    | UserProfiles


dataFromResp : Decode.Decoder a -> RawResponse -> List a
dataFromResp decoder rawResp =
    rawResp.body
        |> Decode.decodeString (Decode.field "results" (Decode.list decoder))
        |> Result.withDefault []


itemFromResp : a -> Decode.Decoder a -> RawResponse -> a
itemFromResp defaultCallback decoder rawResp =
    rawResp.body
        |> Decode.decodeString decoder
        |> Result.withDefault defaultCallback
