module View.Wall exposing (view)

import Html exposing (Html, div, p, span, text)
import Html.Attributes exposing (class, style)
import Messages exposing (Msg)
import Models.Apostello exposing (SmsInbound)


-- Main view


view : List SmsInbound -> Html Msg
view sms =
    div
        [ class "ui grid"
        , style
            [ ( "background-color", "#5c569c" )
            , ( "height", "100vh" )
            , ( "width", "100vw" )
            ]
        ]
        [ div [ class "twelve wide centered column" ]
            [ div [ class "ui one cards" ]
                (sms
                    |> List.filter (\s -> s.display_on_wall)
                    |> List.map smsCard
                )
            ]
        ]


smsCard : SmsInbound -> Html Msg
smsCard sms =
    div [ class "card", style [ ( "backgroundColor", "#ffffff" ), ( "fontSize", "200%" ) ] ]
        [ div [ class "content" ]
            [ p []
                [ span [ style [ ( "color", "#d3d3d3" ) ] ] [ text <| firstWord sms ]
                , text <| restOfMessage sms
                ]
            ]
        ]


firstWord : SmsInbound -> String
firstWord sms =
    sms.content
        |> String.split " "
        |> List.head
        |> Maybe.withDefault ""


restOfMessage : SmsInbound -> String
restOfMessage sms =
    sms.content
        |> String.split " "
        |> List.tail
        |> Maybe.withDefault []
        |> String.join " "
        |> (++) " "
