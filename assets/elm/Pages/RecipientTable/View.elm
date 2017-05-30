module Pages.RecipientTable.View exposing (view)

import Data.Recipient exposing (Recipient)
import Data.Store as Store
import FilteringTable exposing (uiTable)
import Helpers exposing (archiveCell, formatDate)
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes as A
import Messages exposing (Msg(RecipientTableMsg))
import Pages exposing (Page(ContactForm))
import Pages.ContactForm.Model exposing (initialContactFormModel)
import Pages.RecipientTable.Messages exposing (RecipientTableMsg(ToggleRecipientArchive))
import Regex
import Route exposing (spaLink)


-- Main view


view : Regex.Regex -> Store.RemoteList Recipient -> Html Msg
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
    tr [ A.class className ]
        [ td []
            [ spaLink a [] [ text recipient.full_name ] <| ContactForm initialContactFormModel <| Just recipient.pk
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
            div [ A.class "ui horizontal red label" ] [ text "No Reply" ]

        False ->
            text ""
