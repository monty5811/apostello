module Helpers exposing (..)

import Date
import Dict
import Messages exposing (..)
import Models exposing (..)
import Updates.Notification exposing (createLoadingFailedNotification, createNotSavedNotification)
import Regex


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
        |> Dict.values


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



-- sorting functions


sortByTimeReceived : List { a | time_received : String } -> List { a | time_received : String }
sortByTimeReceived items =
    items
        |> List.sortBy compareTR
        |> List.reverse


compareTR : { a | time_received : String } -> Float
compareTR item =
    let
        date =
            Date.fromString item.time_received
    in
        case date of
            Ok d ->
                Date.toTime d

            Err _ ->
                toFloat 1
