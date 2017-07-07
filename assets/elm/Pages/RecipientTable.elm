module Pages.RecipientTable exposing (view)

import Data exposing (Recipient)
import FilteringTable as FT
import Helpers exposing (archiveCell, formatDate)
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes as A
import Messages exposing (Msg(StoreMsg))
import Pages exposing (Page(ContactForm))
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import RemoteList as RL
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleRecipientArchive))


-- Main view


view : FT.Model -> RL.RemoteList Recipient -> Html Msg
view tableModel recipients =
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
    FT.uiTable head tableModel recipientRow recipients


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
        , archiveCell recipient.is_archived (StoreMsg (ToggleRecipientArchive recipient.is_archived recipient.pk))
        ]


doNotReplyIndicator : Bool -> Html Msg
doNotReplyIndicator reply =
    case reply of
        True ->
            div [ A.class "ui horizontal red label" ] [ text "No Reply" ]

        False ->
            text ""
