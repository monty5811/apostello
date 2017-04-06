module View.RecipientTable exposing (view)

import Helpers exposing (formatDate)
import Html exposing (Html, thead, th, td, tr, text, a, div)
import Html.Attributes exposing (class, href)
import Messages exposing (Msg(RecipientTableMsg), RecipientTableMsg(ToggleRecipientArchive))
import Models.Apostello exposing (Recipient)
import Regex
import View.Helpers exposing (archiveCell)
import View.FilteringTable exposing (uiTable)


-- Main view


view : Regex.Regex -> List Recipient -> Html Msg
view filterRegex recipients =
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
        uiTable head filterRegex recipientRow recipients


recipientRow : Recipient -> Html Msg
recipientRow recipient =
    let
        className =
            case recipient.is_blocking of
                True ->
                    "warning"

                False ->
                    ""

        timeReceived =
            case recipient.last_sms of
                Just sms ->
                    sms.time_received

                Nothing ->
                    Nothing

        content =
            case recipient.last_sms of
                Just sms ->
                    sms.content

                Nothing ->
                    ""
    in
        tr [ class className ]
            [ td []
                [ a [ href recipient.url ] [ text recipient.full_name ]
                , doNotReplyIndicator recipient.do_not_reply
                ]
            , td [] [ text content ]
            , td [] [ text <| formatDate timeReceived ]
            , archiveCell recipient.is_archived (RecipientTableMsg (ToggleRecipientArchive recipient.is_archived recipient.pk))
            ]


doNotReplyIndicator : Bool -> Html Msg
doNotReplyIndicator reply =
    case reply of
        True ->
            div [ class "ui horizontal red label" ] [ text "No Reply" ]

        False ->
            text ""
