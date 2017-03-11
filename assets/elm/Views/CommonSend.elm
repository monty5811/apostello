module Views.CommonSend exposing (..)

import Date
import Date.Format
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Messages exposing (..)
import Round
import Views.Helpers exposing (..)


-- Fields


contentField : Int -> List String -> (String -> Msg) -> String -> Html Msg
contentField smsCharLimit errors msg content =
    div [ class (errorFieldClass "required field" errors) ]
        (List.append
            [ label [ for "id_content" ] [ text "Content" ]
            , textarea
                [ id "id_content"
                , name "content"
                , rows (smsCharLimit |> toFloat |> (/) 160 |> ceiling)
                , cols 40
                , onInput msg
                , value content
                ]
                []
            ]
            (List.map fieldMessage errors)
        )


timeField : List String -> Maybe Date.Date -> Html Msg
timeField errors date =
    div [ class (errorFieldClass "field" errors) ]
        (List.append
            [ label [ for "id_scheduled_time" ] [ text "Scheduled time" ]
            , input
                [ attribute "data-field" "datetime"
                , id "id_scheduled_time"
                , name "scheduled_time"
                , readonly True
                , type_ "text"
                , value <|
                    Maybe.withDefault "" <|
                        Maybe.map (Date.Format.format "%Y-%m-%d %H:%M") <|
                            date
                ]
                []
            , div [ class "ui label" ]
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
        [ class ("ui " ++ sendButtonClass cost ++ " button"), id "send_button", onClick msg ]
        [ text ("Send ($" ++ sendButtonText cost ++ ")") ]



-- Helpers


fieldMessage : String -> Html Msg
fieldMessage message =
    div [ class "ui error message" ] [ text message ]


errorFieldClass : String -> List String -> String
errorFieldClass base errors =
    case List.isEmpty errors of
        True ->
            base

        False ->
            "error " ++ base
