module Pages.KeyRespTable.View exposing (view)

import Data.SmsInbound exposing (SmsInbound)
import FilteringTable.Model as FTM
import FilteringTable.View exposing (uiTable)
import Helpers exposing (archiveCell, formatDate)
import Html exposing (Html, a, br, button, div, i, input, label, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, checked, class, id, name, style, type_)
import Html.Events exposing (onClick, onSubmit)
import Messages exposing (Msg(KeyRespTableMsg, StoreMsg))
import Pages exposing (Page(ContactForm), initSendAdhoc)
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import Pages.KeyRespTable.Messages exposing (KeyRespTableMsg(..))
import RemoteList as RL
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleInboundSmsArchive, ToggleInboundSmsDealtWith))


-- Main view


view : Bool -> FTM.Model -> RL.RemoteList SmsInbound -> Bool -> String -> Html Msg
view viewingArchive tableModel sms ticked keyword =
    div []
        [ uiTable tableHead tableModel smsRow sms
        , br [] []
        , archiveAllForm viewingArchive ticked keyword
        ]


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "From" ]
            , th [] [ text "Time Received" ]
            , th [] [ text "Message" ]
            , th [] [ text "Requires Action?" ]
            , th [] []
            ]
        ]


archiveAllForm : Bool -> Bool -> String -> Html Msg
archiveAllForm viewingArchive ticked k =
    case viewingArchive of
        True ->
            text ""

        False ->
            Html.form [ onSubmit (KeyRespTableMsg <| ArchiveAllButtonClick k) ]
                [ div [ class "field" ]
                    [ div [ class "ui checkbox" ]
                        [ input
                            [ id "id_tick_to_archive_all_responses"
                            , name "tick_to_archive_all_responses"
                            , attribute "required" ""
                            , type_ "checkbox"
                            , checked ticked
                            , onClick (KeyRespTableMsg ArchiveAllCheckBoxClick)
                            ]
                            []
                        , label [] [ text "Tick to archive all responses" ]
                        ]
                    ]
                , br [] []
                , archiveAllButton ticked
                ]


archiveAllButton : Bool -> Html Msg
archiveAllButton ticked =
    case ticked of
        True ->
            button [ class "ui red button" ] [ text "Archive all!" ]

        False ->
            button [ class "ui disabled button" ] [ text "Archive all!" ]


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
        , td [ class "collapsing" ] [ text (formatDate sms.time_received) ]
        , td [] [ text sms.content ]
        , td [ class "collapsing" ] [ dealtWithButton sms ]
        , archiveCell sms.is_archived (StoreMsg (ToggleInboundSmsArchive sms.is_archived sms.pk))
        ]


recipientCell : SmsInbound -> Html Msg
recipientCell sms =
    let
        replyPage =
            initSendAdhoc Nothing <| Maybe.map List.singleton sms.sender_pk

        contactPage =
            ContactForm initialContactFormModel <| sms.sender_pk
    in
    td []
        [ spaLink a [] [ i [ class "violet reply link icon" ] [] ] replyPage
        , spaLink a [ style [ ( "color", "#212121" ) ] ] [ text sms.sender_name ] contactPage
        ]


dealtWithButton : SmsInbound -> Html Msg
dealtWithButton sms =
    case sms.dealt_with of
        True ->
            button
                [ class "ui tiny positive icon button"
                , onClick (StoreMsg (ToggleInboundSmsDealtWith sms.dealt_with sms.pk))
                ]
                [ i [ class "checkmark icon" ] [], text "Dealt With" ]

        False ->
            button
                [ class "ui tiny orange icon button"
                , onClick (StoreMsg (ToggleInboundSmsDealtWith sms.dealt_with sms.pk))
                ]
                [ i [ class "attention icon" ] [], text "Requires Action" ]
