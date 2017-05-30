module Pages.Curator exposing (view)

import Data.SmsInbound exposing (SmsInbound)
import Data.Store as Store
import FilteringTable exposing (uiTable)
import Helpers exposing (formatDate)
import Html exposing (Html, a, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(WallMsg))
import Pages.Wall.Messages exposing (WallMsg(ToggleWallDisplay))
import Regex


-- Main view


view : Regex.Regex -> Store.RemoteList SmsInbound -> Html Msg
view filterRegex sms =
    let
        head =
            thead []
                [ tr []
                    [ th [] [ text "Message" ]
                    , th [] [ text "Time" ]
                    , th [] [ text "Display?" ]
                    ]
                ]
    in
    uiTable head filterRegex smsRow sms


smsRow : SmsInbound -> Html Msg
smsRow sms =
    tr []
        [ td [] [ text sms.content ]
        , td [ class "collapsing" ] [ text (formatDate sms.time_received) ]
        , curateToggleCell sms
        ]


curateToggleCell : SmsInbound -> Html Msg
curateToggleCell sms =
    let
        text_ =
            case sms.display_on_wall of
                True ->
                    "Showing"

                False ->
                    "Hidden"

        colour =
            case sms.display_on_wall of
                True ->
                    "green"

                False ->
                    "red"

        className =
            "ui tiny " ++ colour ++ " fluid button"
    in
    td [ class "collapsing" ]
        [ a
            [ class className
            , onClick (WallMsg (ToggleWallDisplay sms.display_on_wall sms.pk))
            ]
            [ text text_ ]
        ]
