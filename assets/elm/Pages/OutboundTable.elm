module Pages.OutboundTable exposing (view)

import Data exposing (SmsOutbound)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html, td, text, th, thead, tr)
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


tableHead : Html msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "To" ]
            , th [] [ text "Message" ]
            , th [] [ text "Sent" ]
            ]
        ]


smsRow : Props msg -> SmsOutbound -> ( String, Html msg )
smsRow props sms =
    let
        recipient =
            case sms.recipient of
                Just r ->
                    r

                Nothing ->
                    { full_name = "", pk = 0 }
    in
    ( toString sms.pk
    , tr []
        [ td [] [ props.contactLink recipient ]
        , td [] [ text sms.content ]
        , td [] [ text (formatDate sms.time_sent) ]
        ]
    )
