module Store.Request exposing (..)

import Http
import Json.Decode as Decode
import Messages exposing (Msg(StoreMsg))
import Models exposing (Model)
import Regex
import Store.DataTypes exposing (RemoteDataType, dt2Url, dt_from_page)
import Store.Messages exposing (StoreMsg(ReceiveRawResp))
import Store.Model exposing (RawResponse, setLoadDataStatus)


maybeFetchData : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
maybeFetchData ( model, cmds ) =
    let
        dataTypes =
            dt_from_page model.page

        newDs =
            dataTypes
                |> List.foldl setLoadDataStatus model.dataStore

        fetchCmds =
            dataTypes
                |> List.map (\dt -> ( dt, dt2Url dt ))
                |> List.map fetchData
    in
    ( { model | dataStore = newDs }, List.concat [ fetchCmds, cmds ] )


fetchData : ( RemoteDataType, ( Bool, String ) ) -> Cmd Msg
fetchData ( dt, ( ignorePageInfo, url ) ) =
    makeRequest url
        |> Http.send (StoreMsg << ReceiveRawResp dt ignorePageInfo)


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



-- increase page size for next response


increasePageSize : String -> String
increasePageSize url =
    case String.contains "page_size" url of
        True ->
            Regex.replace Regex.All
                (Regex.regex "page=2&page_size=100$")
                (\_ -> "page_size=1000")
                url

        False ->
            Regex.replace Regex.All
                (Regex.regex "page=2$")
                (\_ -> "page_size=100")
                url
