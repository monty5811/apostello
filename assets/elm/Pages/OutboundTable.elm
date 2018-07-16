module Pages.OutboundTable exposing (view)

import Css
import Data exposing (SmsOutbound, stringFromMDStatus)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html)
import RemoteList as RL


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , tableModel : FT.Model
    , sms : RL.RemoteList SmsOutbound
    , contactLink : { full_name : String, pk : Int } -> Html msg
    }


view : Props msg -> Html msg
view props =
    FT.defaultTable { top = props.tableMsg } tableHead props.tableModel (smsRow props) props.sms


tableHead : FT.Head
tableHead =
    FT.Head
        [ "To"
        , "Message"
        , "Sent"
        , "Status from Twilio"
        ]


smsRow : Props msg -> SmsOutbound -> FT.Row msg
smsRow props sms =
    let
        recipient =
            case sms.recipient of
                Just r ->
                    r

                Nothing ->
                    { full_name = "", pk = 0 }
    in
    FT.Row
        []
        [ FT.Cell [] [ props.contactLink recipient ]
        , FT.Cell [] [ Html.text sms.content ]
        , FT.Cell [ Css.collapsing ] [ Html.text <| formatDate sms.time_sent ]
        , FT.Cell [ Css.collapsing ] [ Html.text <| stringFromMDStatus sms.status ]
        ]
        (toString sms.pk)
