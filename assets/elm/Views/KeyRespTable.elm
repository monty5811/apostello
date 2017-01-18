module Views.KeyRespTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Views.Common exposing (archiveCell)
import Views.FilteringTable exposing (filteringTable)


-- Main view


view : Regex.Regex -> KeyRespTableModel -> Html Msg
view filterRegex model =
    let
        head =
            thead []
                [ tr []
                    [ th [] [ text "From" ]
                    , th [] [ text "Time Received" ]
                    , th [] [ text "Message" ]
                    , th [] [ text "Requires Action?" ]
                    , th [] []
                    ]
                ]
    in
        filteringTable filterRegex smsRow model.sms head "ui table"


smsRow : SmsInbound -> Html Msg
smsRow sms =
    let
        className =
            case sms.dealt_with of
                True ->
                    ""

                False ->
                    "warning"
    in
        tr [ class className ]
            [ recipientCell sms
            , td [ class "collapsing" ] [ text sms.time_received ]
            , td [] [ text sms.content ]
            , td [ class "collapsing" ] [ dealtWithButton sms ]
            , archiveCell sms.is_archived (KeyRespTableMsg (ToggleInboundSmsArchive sms.is_archived sms.pk))
            ]


recipientCell : SmsInbound -> Html Msg
recipientCell sms =
    let
        replyLink =
            case sms.sender_pk of
                Just pk ->
                    "/send/adhoc/?recipient=" ++ (toString sms.sender_pk)

                Nothing ->
                    "#"

        contactLink =
            case sms.sender_url of
                Just url ->
                    url

                Nothing ->
                    "#"
    in
        td []
            [ a [ href replyLink ] [ i [ class "violet reply link icon" ] [] ]
            , a [ href contactLink, style [ ( "color", "#212121" ) ] ] [ text sms.sender_name ]
            ]


dealtWithButton : SmsInbound -> Html Msg
dealtWithButton sms =
    case sms.dealt_with of
        True ->
            button [ class "ui tiny positive icon button", onClick (KeyRespTableMsg (ToggleInboundSmsDealtWith sms.dealt_with sms.pk)) ] [ i [ class "checkmark icon" ] [], text "Dealt With" ]

        False ->
            button [ class "ui tiny orange icon button", onClick (KeyRespTableMsg (ToggleInboundSmsDealtWith sms.dealt_with sms.pk)) ] [ i [ class "attention icon" ] [], text "Requires Action" ]
