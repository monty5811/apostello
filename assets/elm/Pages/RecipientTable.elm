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
import Rocket exposing ((=>))
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
                    , th [ A.class "hide-sm-down" ] []
                    ]
                ]
    in
    FT.defaultTable head tableModel recipientRow recipients


recipientRow : Recipient -> ( String, Html Msg )
recipientRow recipient =
    let
        style =
            case recipient.is_blocking of
                True ->
                    [ "background" => "var(--color-red)" ]

                False ->
                    []

        timeReceived =
            Maybe.andThen .time_received recipient.last_sms

        content =
            case recipient.last_sms of
                Just sms ->
                    sms.content

                Nothing ->
                    ""
    in
    ( toString recipient.pk
    , tr [ A.style style ]
        [ td []
            [ spaLink a [] [ text recipient.full_name ] <| ContactForm initialContactFormModel <| Just recipient.pk
            , doNotReplyIndicator recipient.do_not_reply
            ]
        , td [] [ text content ]
        , td [] [ text <| formatDate timeReceived ]
        , archiveCell recipient.is_archived (StoreMsg (ToggleRecipientArchive recipient.is_archived recipient.pk))
        ]
    )


doNotReplyIndicator : Bool -> Html Msg
doNotReplyIndicator reply =
    case reply of
        True ->
            div [ A.class "badge badge-danger" ] [ text "No Reply" ]

        False ->
            text ""
