module FilteringTable exposing (filterRecord, filteringTable, textToRegex, uiTable)

import Data.Store as Store
import Html exposing (Html, div, i, input, table, tbody, text)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onInput)
import Messages exposing (Msg(UpdateTableFilter))
import Regex


filterRecord : Regex.Regex -> a -> Bool
filterRecord regex record =
    Regex.contains regex (toString record)


textToRegex : String -> Regex.Regex
textToRegex t =
    t
        |> Regex.escape
        |> Regex.regex
        |> Regex.caseInsensitive


emptyView : Html Msg
emptyView =
    div [ class "ui message" ] [ text "No data to display" ]


loadingView : Html Msg
loadingView =
    div [ class "ui active loader" ] []


filteringTable : String -> Html Msg -> Regex.Regex -> (a -> Html Msg) -> Store.RemoteList a -> Html Msg
filteringTable tableClass tableHead filterRegex rowConstructor data =
    let
        rows =
            data
                |> Store.toList
                |> List.filter (filterRecord filterRegex)
                |> List.map rowConstructor
    in
    case List.length rows of
        0 ->
            case data of
                Store.NotAsked _ ->
                    loadingView

                Store.WaitingForFirstResp _ ->
                    loadingView

                _ ->
                    emptyView

        _ ->
            div []
                [ div [ class "ui left icon large transparent fluid input" ]
                    [ i [ class "violet filter icon" ] []
                    , input
                        [ type_ "text"
                        , placeholder "Filter..."
                        , onInput UpdateTableFilter
                        ]
                        []
                    ]
                , table [ class tableClass ]
                    [ tableHead
                    , tbody [] rows
                    ]
                ]


uiTable : Html Msg -> Regex.Regex -> (a -> Html Msg) -> Store.RemoteList a -> Html Msg
uiTable tableHead filterRegex rowConstructor data =
    filteringTable "ui table" tableHead filterRegex rowConstructor data
