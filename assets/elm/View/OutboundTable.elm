module View.OutboundTable exposing (view)

import Helpers exposing (formatDate)
import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Messages exposing (Msg)
import Models.Apostello exposing (SmsOutbound)
import Pages exposing (Page(EditContact))
import Regex
import Route exposing (page2loc)
import View.FilteringTable exposing (uiTable)


-- Main view


view : Regex.Regex -> List SmsOutbound -> Html Msg
view filterRegex sms =
    uiTable tableHead filterRegex smsRow sms


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "To" ]
            , th [] [ text "Message" ]
            , th [] [ text "Sent" ]
            ]
        ]


smsRow : SmsOutbound -> Html Msg
smsRow sms =
    let
        recipient =
            case sms.recipient of
                Just r ->
                    r

                Nothing ->
                    { full_name = "", pk = 0 }
    in
        tr []
            [ td [ class "collapsing" ]
                [ a
                    [ href <| page2loc <| EditContact recipient.pk
                    , style [ ( "color", "#212121" ) ]
                    ]
                    [ text recipient.full_name ]
                ]
            , td [] [ text sms.content ]
            , td [ class "collapsing" ] [ text (formatDate sms.time_sent) ]
            ]
