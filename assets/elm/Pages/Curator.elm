module Pages.Curator exposing (view)

import Css
import Data exposing (SmsInbound)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html)
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
    FT.defaultTable { top = tableMsg } head tableModel (smsRow toggleWallDisplay) sms


head : FT.Head
head =
    FT.Head
        [ "Message"
        , "Time"
        , "Display?"
        ]


smsRow : (Bool -> Int -> msg) -> SmsInbound -> FT.Row msg
smsRow toggleWallDisplay sms =
    FT.Row
        []
        [ FT.Cell [] [ Html.text sms.content ]
        , FT.Cell [] [ Html.text <| formatDate sms.time_received ]
        , curateToggleCell toggleWallDisplay sms
        ]
        (toString sms.pk)


curateToggleCell : (Bool -> Int -> msg) -> SmsInbound -> FT.Cell msg
curateToggleCell toggleWallDisplay sms =
    let
        ( text_, colour ) =
            case sms.display_on_wall of
                True ->
                    ( "Showing", Css.btn_green )

                False ->
                    ( "Hidden", Css.btn_red )
    in
    FT.Cell
        [ Css.collapsing ]
        [ Html.a
            [ onClick (toggleWallDisplay sms.display_on_wall sms.pk)
            , Css.btn
            , colour
            ]
            [ Html.text text_ ]
        ]
