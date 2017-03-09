module Views.Wall exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Messages exposing (..)
import Models exposing (..)


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
    let
        firstWord =
            sms.content
                |> String.split " "
                |> List.head
                |> Maybe.withDefault ""

        restOfMessage =
            sms.content
                |> String.split " "
                |> List.tail
                |> Maybe.withDefault []
                |> String.join " "
                |> (++) " "
    in
        div [ class "card", style [ ( "backgroundColor", "#ffffff" ), ( "fontSize", "200%" ) ] ]
            [ div [ class "content" ]
                [ p []
                    [ span [ style [ ( "color", "#d3d3d3" ) ] ] [ text firstWord ]
                    , text restOfMessage
                    ]
                ]
            ]
