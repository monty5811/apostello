module Pages.Curator exposing (view)

import Data exposing (SmsInbound)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html, a, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import RemoteList as RL


-- Main view


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , tableModel : FT.Model
    , sms : RL.RemoteList SmsInbound
    , toggleWallDisplay : Bool -> Int -> msg
    }


view : Props msg -> Html msg
view { tableMsg, tableModel, sms, toggleWallDisplay } =
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
    FT.defaultTable { top = tableMsg } head tableModel (smsRow toggleWallDisplay) sms


smsRow : (Bool -> Int -> msg) -> SmsInbound -> ( String, Html msg )
smsRow toggleWallDisplay sms =
    ( toString sms.pk
    , tr
        []
        [ td [] [ text sms.content ]
        , td [] [ text (formatDate sms.time_received) ]
        , curateToggleCell toggleWallDisplay sms
        ]
    )


curateToggleCell : (Bool -> Int -> msg) -> SmsInbound -> Html msg
curateToggleCell toggleWallDisplay sms =
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
                    "button-success"

                False ->
                    "button-danger"

        className =
            "button " ++ colour
    in
    td []
        [ a
            [ class className
            , onClick (toggleWallDisplay sms.display_on_wall sms.pk)
            ]
            [ text text_ ]
        ]
