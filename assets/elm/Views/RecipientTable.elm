module Views.RecipientTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Views.Common exposing (archiveCell)
import Views.FilteringTable exposing (filteringTable)


-- Main view


view : Regex.Regex -> RecipientTableModel -> Html Msg
view filterRegex model =
    let
        head =
            thead []
                [ tr []
                    [ th [] [ text "Name" ]
                    , th [] [ text "Last Message" ]
                    , th [] [ text "Received" ]
                    , th [] []
                    ]
                ]
    in
        filteringTable filterRegex recipientRow model.recipients head "ui table"


recipientRow : Recipient -> Html Msg
recipientRow recipient =
    let
        className =
            case recipient.is_blocking of
                True ->
                    "warning"

                False ->
                    ""

        lastSms =
            case recipient.last_sms of
                Just sms ->
                    sms

                Nothing ->
                    SmsInboundSimple 0 "" "" False False ""
    in
        tr [ class className ]
            [ td []
                [ a [ href recipient.url ] [ text recipient.full_name ]
                , doNotReplyIndicator recipient.do_not_reply
                ]
            , td [] [ text lastSms.content ]
            , td [] [ text lastSms.time_received ]
            , archiveCell recipient.is_archived (RecipientTableMsg (ToggleRecipientArchive recipient.is_archived recipient.pk))
            ]


doNotReplyIndicator : Bool -> Html Msg
doNotReplyIndicator reply =
    case reply of
        True ->
            div [ class "ui horizontal red label" ] [ text "No Reply" ]

        False ->
            text ""
