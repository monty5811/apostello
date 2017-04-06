module View.CommonSend
    exposing
        ( contentField
        , timeField
        , sendButtonClass
        , sendButtonText
        , sendButton
        , fieldMessage
        , errorFieldClass
        )

import Date
import Date.Format
import Html exposing (Html, label, textarea, div, text, button, input)
import Html.Attributes as A
import Html.Events exposing (onInput)
import Messages exposing (Msg)
import Round
import View.Helpers exposing (onClick)


-- Fields


contentField : Int -> List String -> (String -> Msg) -> String -> Html Msg
contentField smsCharLimit errors msg content =
    div [ A.class (errorFieldClass "required field" errors) ]
        (List.append
            [ label [ A.for "id_content" ] [ text "Content" ]
            , textarea
                [ A.id "id_content"
                , A.name "content"
                , A.rows (smsCharLimit |> toFloat |> (/) 160 |> ceiling)
                , A.cols 40
                , onInput msg
                , A.value content
                ]
                []
            ]
            (List.map fieldMessage errors)
        )


timeField : List String -> Maybe Date.Date -> Html Msg
timeField errors date =
    div [ A.class (errorFieldClass "field" errors) ]
        (List.append
            [ label [ A.for "id_scheduled_time" ] [ text "Scheduled time" ]
            , input
                [ A.attribute "data-field" "datetime"
                , A.id "id_scheduled_time"
                , A.name "scheduled_time"
                , A.readonly True
                , A.type_ "text"
                , A.value <|
                    Maybe.withDefault "" <|
                        Maybe.map (Date.Format.format "%Y-%m-%d %H:%M") <|
                            date
                ]
                []
            , div [ A.class "ui label" ]
                [ text "Leave this blank to send your message immediately, otherwise select a date and time to schedule your message"
                ]
            ]
            (List.map fieldMessage errors)
        )



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


sendButton : Msg -> Maybe Float -> Html Msg
sendButton msg cost =
    button
        [ A.class ("ui " ++ sendButtonClass cost ++ " button"), A.id "send_button", onClick msg ]
        [ text ("Send ($" ++ sendButtonText cost ++ ")") ]



-- Helpers


fieldMessage : String -> Html Msg
fieldMessage message =
    div [ A.class "ui error message" ] [ text message ]


errorFieldClass : String -> List String -> String
errorFieldClass base errors =
    case List.isEmpty errors of
        True ->
            base

        False ->
            "error " ++ base
