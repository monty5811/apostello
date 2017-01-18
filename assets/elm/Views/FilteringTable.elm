module Views.FilteringTable exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onClick, onInput)
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


filteringTable : Regex.Regex -> (a -> Html Msg) -> List a -> Html Msg -> String -> Html Msg
filteringTable filterRegex rowConstructor data tableHead tableClass =
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
