module Pages.Wall exposing (view)

import Data exposing (SmsInbound)
import Html exposing (Html, div, p, span, text)
import Html.Attributes exposing (class, style)
import RemoteList as RL


-- Main view


view : RL.RemoteList SmsInbound -> Html msg
view sms =
    div
        [ class "text-center"
        , style
            [ ( "background-color", "#5c569c" )
            , ( "height", "100vh" )
            , ( "width", "100vw" )
            ]
        ]
        [ div [ style [ ( "padding", "2rem" ) ] ]
            (sms
                |> RL.toList
                |> List.filter (\s -> s.display_on_wall)
                |> List.map smsCard
            )
        ]


smsCard : SmsInbound -> Html msg
smsCard sms =
    div
        [ style
            [ ( "backgroundColor", "#ffffff" )
            , ( "fontSize", "200%" )
            , ( "padding", ".5rem" )
            , ( "margin", ".5rem" )
            ]
        ]
        [ p []
            [ span [ style [ ( "color", "#d3d3d3" ) ] ] [ text <| firstWord sms ]
            , text <| restOfMessage sms
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
