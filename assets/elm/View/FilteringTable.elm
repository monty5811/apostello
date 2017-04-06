module View.FilteringTable exposing (filteringTable, filterRecord, uiTable, textToRegex)

import Html exposing (Html, div, i, input, table, tbody)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onInput)
import Messages exposing (Msg(UpdateTableFilter))
import Regex


filterRecord : Regex.Regex -> a -> Bool
filterRecord regex record =
    Regex.contains regex (toString record)


textToRegex : String -> Regex.Regex
textToRegex text =
    text
        |> Regex.escape
        |> Regex.regex
        |> Regex.caseInsensitive


filteringTable : String -> Html Msg -> Regex.Regex -> (a -> Html Msg) -> List a -> Html Msg
filteringTable tableClass tableHead filterRegex rowConstructor data =
    let
        rows =
            data
                |> List.filter (filterRecord filterRegex)
                |> List.map rowConstructor
    in
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


uiTable : Html Msg -> Regex.Regex -> (a -> Html Msg) -> List a -> Html Msg
uiTable tableHead filterRegex rowConstructor data =
    filteringTable "ui table" tableHead filterRegex rowConstructor data
