module Forms.View.Send
    exposing
        ( contentField
        , sendButton
        , sendButtonClass
        , sendButtonText
        , timeField
        )

import Date
import DateTimePicker
import Forms.Model exposing (FieldMeta)
import Forms.View exposing (dateTimeField)
import Html exposing (Html, button, label, text, textarea)
import Html.Attributes as A
import Html.Events exposing (onInput)
import Messages exposing (Msg)
import Round


-- Fields


contentField : FieldMeta -> Int -> (String -> Msg) -> String -> List (Html Msg)
contentField meta smsCharLimit msg content =
    [ label [ A.for meta.id ] [ text meta.label ]
    , textarea
        [ A.id meta.id
        , A.name meta.name
        , A.rows (smsCharLimit |> toFloat |> (/) 160 |> ceiling)
        , A.cols 40
        , onInput msg
        , A.value content
        ]
        []
    ]


timeField : (DateTimePicker.State -> Maybe Date.Date -> Msg) -> FieldMeta -> DateTimePicker.State -> Maybe Date.Date -> List (Html Msg)
timeField msg meta datePickerState date =
    dateTimeField msg meta datePickerState date



-- Send Button


sendButtonClass : Maybe Float -> String
sendButtonClass cost =
    case cost of
        Nothing ->
            "disabled"

        Just _ ->
            "primary"


sendButtonText : Maybe Float -> String
sendButtonText cost =
    case cost of
        Nothing ->
            "0.00"

        Just c ->
            Round.round 2 c


sendButton : Maybe Float -> Html Msg
sendButton cost =
    button
        [ A.class ("ui " ++ sendButtonClass cost ++ " button"), A.id "send_button" ]
        [ text ("Send ($" ++ sendButtonText cost ++ ")") ]
