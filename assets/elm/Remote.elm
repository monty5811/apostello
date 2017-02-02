module Remote exposing (..)

import Http
import Messages exposing (..)
import Models exposing (..)
import Json.Decode as Decode


fetchData : String -> Cmd Msg
fetchData dataUrl =
    makeRequest dataUrl
        |> Http.send ReceiveRawResp


makeRequest : String -> Http.Request RawResponse
makeRequest dataUrl =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json" ]
        , url = dataUrl
        , body = Http.emptyBody
        , expect =
            Http.expectStringResponse (\resp -> Ok (extractRawResponse resp))
        , timeout = Nothing
        , withCredentials = True
        }


extractRawResponse : Http.Response String -> RawResponse
extractRawResponse resp =
    { body = resp.body
    , next = nextFromBody resp.body
    }


nextFromBody : String -> Maybe String
nextFromBody body =
    body
        |> Decode.decodeString (Decode.field "next" (Decode.maybe Decode.string))
        |> Result.withDefault Nothing
