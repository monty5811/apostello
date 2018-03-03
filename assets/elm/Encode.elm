module Encode exposing (encodeDate, encodeMaybe, encodeMaybeDate, encodeMaybeDateOnly)

import Date
import DateFormat
import Json.Encode as Encode


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder ms =
    case ms of
        Nothing ->
            Encode.null

        Just s ->
            encoder s


encodeMaybeDate : Maybe Date.Date -> Encode.Value
encodeMaybeDate date =
    date
        |> Maybe.map
            (DateFormat.format
                [ DateFormat.yearNumber
                , DateFormat.text "-"
                , DateFormat.monthFixed
                , DateFormat.text "-"
                , DateFormat.dayOfMonthFixed
                , DateFormat.text " "
                , DateFormat.hourMilitaryFixed
                , DateFormat.text ":"
                , DateFormat.minuteFixed
                , DateFormat.text ":"
                , DateFormat.secondFixed
                ]
            )
        |> encodeMaybe Encode.string


encodeMaybeDateOnly : Maybe Date.Date -> Encode.Value
encodeMaybeDateOnly date =
    date
        |> Maybe.map
            (DateFormat.format
                [ DateFormat.yearNumber
                , DateFormat.text "-"
                , DateFormat.monthFixed
                , DateFormat.text "-"
                , DateFormat.dayOfMonthFixed
                ]
            )
        |> encodeMaybe Encode.string


encodeDate : Date.Date -> Encode.Value
encodeDate date =
    date
        |> DateFormat.format
            [ DateFormat.yearNumber
            , DateFormat.text "-"
            , DateFormat.monthFixed
            , DateFormat.text "-"
            , DateFormat.dayOfMonthFixed
            , DateFormat.text " "
            , DateFormat.hourMilitaryFixed
            , DateFormat.text ":"
            , DateFormat.minuteFixed
            , DateFormat.text ":"
            , DateFormat.secondFixed
            ]
        |> Encode.string
