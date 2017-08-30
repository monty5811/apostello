module Pages.KeyRespTable.View exposing (view)

import Data exposing (SmsInbound)
import FilteringTable as FT
import Helpers exposing (archiveCell, formatDate)
import Html exposing (Html, a, br, button, div, i, input, label, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events exposing (onClick, onSubmit)
import Messages exposing (Msg(KeyRespTableMsg, StoreMsg))
import Pages exposing (Page(ContactForm), initSendAdhoc)
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import Pages.KeyRespTable.Messages exposing (KeyRespTableMsg(..))
import RemoteList as RL
import Rocket exposing ((=>))
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleInboundSmsArchive, ToggleInboundSmsDealtWith))


-- Main view


view : Bool -> FT.Model -> RL.RemoteList SmsInbound -> Bool -> String -> Html Msg
view viewingArchive tableModel sms ticked keyword =
    div []
        [ FT.uiTable tableHead tableModel smsRow sms
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
                [ div [ A.class "input-field" ]
                    [ Html.label []
                        [ input
                            [ A.id "id_tick_to_archive_all_responses"
                            , A.name "tick_to_archive_all_responses"
                            , A.attribute "required" ""
                            , A.type_ "checkbox"
                            , A.checked ticked
                            , onClick (KeyRespTableMsg ArchiveAllCheckBoxClick)
                            ]
                            []
                        , text " Tick to archive all responses"
                        ]
                    ]
                , archiveAllButton ticked
                ]


archiveAllButton : Bool -> Html Msg
archiveAllButton ticked =
    case ticked of
        True ->
            button [ A.class "button button-danger", A.id "archiveAllSmsButton" ] [ text "Archive all!" ]

        False ->
            button [ A.class "button button-danger", A.disabled True ] [ text "Archive all!" ]


smsRow : SmsInbound -> Html Msg
smsRow sms =
    tr []
        [ recipientCell sms
        , td [] [ text (formatDate sms.time_received) ]
        , td [] [ text sms.content ]
        , td [] [ dealtWithButton sms ]
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
        [ spaLink a [] [ i [ A.class "fa fa-reply" ] [] ] replyPage
        , spaLink a [ A.style [ "color" => "var(--color-black)" ] ] [ text sms.sender_name ] contactPage
        ]


dealtWithButton : SmsInbound -> Html Msg
dealtWithButton sms =
    case sms.dealt_with of
        True ->
            button
                [ A.class "button button-success"
                , onClick (StoreMsg (ToggleInboundSmsDealtWith sms.dealt_with sms.pk))
                , A.id "unDealWithButton"
                ]
                [ i [ A.class "fa fa-check" ] [], text " Dealt With" ]

        False ->
            button
                [ A.class "button button-warning"
                , onClick (StoreMsg (ToggleInboundSmsDealtWith sms.dealt_with sms.pk))
                , A.id "dealWithButton"
                ]
                [ i [ A.class "fa fa-exclamation" ] [], text " Requires Action" ]
