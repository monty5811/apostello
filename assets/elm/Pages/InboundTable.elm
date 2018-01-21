module Pages.InboundTable exposing (view)

import Data exposing (SmsInbound)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html, a, b, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events as E
import RemoteList as RL


-- Main view


type alias Props msg =
    { tableModel : FT.Model
    , tableMsg : FT.Msg -> msg
    , sms : RL.RemoteList SmsInbound
    , reprocessSms : Int -> msg
    , keywordFormLink : SmsInbound -> Html msg
    , contactPageLink : SmsInbound -> Html msg
    , replyPageLink : SmsInbound -> Html msg
    }


view : Props msg -> Html msg
view props =
    let
        head =
            thead []
                [ tr []
                    [ th [] [ text "From" ]
                    , th [] [ text "Keyword" ]
                    , th [] [ text "Message" ]
                    , th [] [ text "Time" ]
                    , th [] []
                    ]
                ]
    in
    FT.defaultTable { top = props.tableMsg } head props.tableModel (smsRow props) props.sms


smsRow : Props msg -> SmsInbound -> ( String, Html msg )
smsRow props sms =
    ( toString sms.pk
    , tr [ A.style [ ( "backgroundColor", sms.matched_colour ) ] ]
        [ recipientCell props sms
        , keywordCell props sms
        , td [] [ text sms.content ]
        , td [] [ text (formatDate sms.time_received) ]
        , reprocessCell props sms
        ]
    )


recipientCell : Props msg -> SmsInbound -> Html msg
recipientCell props sms =
    td []
        [ props.replyPageLink sms
        , props.contactPageLink sms
        ]


keywordCell : Props msg -> SmsInbound -> Html msg
keywordCell props sms =
    case sms.matched_keyword of
        "#" ->
            td [] [ b [] [ text sms.matched_keyword ] ]

        "No Match" ->
            td [] [ b [] [ text sms.matched_keyword ] ]

        _ ->
            td []
                [ b []
                    [ props.keywordFormLink sms ]
                ]


reprocessCell : Props msg -> SmsInbound -> Html msg
reprocessCell props sms =
    td []
        [ a
            [ A.class "button button-info"
            , A.id "reingestButton"
            , E.onClick (props.reprocessSms sms.pk)
            ]
            [ text "Reprocess" ]
        ]
