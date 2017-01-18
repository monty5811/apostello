module Views.Wall exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Messages exposing (..)
import Models exposing (..)


-- Main view


view : WallModel -> Html Msg
view model =
    div [ class "ui stackable grid container" ]
        [ div [ class "sixteen wide centered column" ]
            [ div [ class "ui one cards" ]
                (model.sms
                    |> List.filter (\s -> s.display_on_wall)
                    |> List.map smsCard
                )
            ]
        ]


smsCard : SmsInboundSimple -> Html Msg
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
