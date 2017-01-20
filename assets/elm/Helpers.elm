module Helpers exposing (..)

import Decoders exposing (..)
import Dict
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Updates.Notification exposing (createLoadingFailedNotification, createNotSavedNotification)
import Regex


encodeBody : List ( String, Encode.Value ) -> Http.Body
encodeBody data =
    data
        |> Encode.object
        |> Http.jsonBody



-- Fetch data from server


getData : String -> Decode.Decoder a -> Http.Request a
getData url decoder =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }


getApostelloResponse : String -> Decode.Decoder a -> Http.Request (ApostelloResponse a)
getApostelloResponse url decoder =
    getData url (decodeApostelloResponse decoder)



-- determine loading status


determineLoadingStatus : ApostelloResponse a -> LoadingStatus
determineLoadingStatus resp =
    case resp.next of
        Nothing ->
            Finished

        _ ->
            WaitingForSubsequent



-- increase page size for next response


increasePageSize : String -> String
increasePageSize url =
    case Regex.contains (Regex.regex "page_size") url of
        True ->
            Regex.replace (Regex.AtMost 1) (Regex.regex "page=2&page_size=100$") (\_ -> "page_size=1000") url

        False ->
            Regex.replace (Regex.AtMost 1) (Regex.regex "page=2$") (\_ -> "page_size=100") url



-- merge new items with existing


mergeItems : List { a | pk : Int } -> List { a | pk : Int } -> List { a | pk : Int }
mergeItems existingItems newItems =
    existingItems
        |> List.map (\x -> ( x.pk, x ))
        |> Dict.fromList
        |> addNewItems newItems
        |> Dict.toList
        |> List.map (\x -> Tuple.second x)


addNewItems : List { a | pk : Int } -> Dict.Dict Int { a | pk : Int } -> Dict.Dict Int { a | pk : Int }
addNewItems newItems existingItemsDict =
    newItems
        |> List.foldl addItemToDic existingItemsDict


addItemToDic : { a | pk : Int } -> Dict.Dict Int { a | pk : Int } -> Dict.Dict Int { a | pk : Int }
addItemToDic item existingItems =
    Dict.insert item.pk item existingItems



-- update model after http errors:


handleLoadingFailed : Model -> ( Model, Cmd Msg )
handleLoadingFailed model =
    ( { model | loadingStatus = Finished } |> createLoadingFailedNotification, Cmd.none )


handleNotSaved : Model -> ( Model, Cmd Msg )
handleNotSaved model =
    ( createNotSavedNotification model, Cmd.none )
