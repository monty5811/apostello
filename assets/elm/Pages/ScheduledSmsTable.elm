module Pages.ScheduledSmsTable exposing (view)

import Data.QueuedSms exposing (QueuedSms)
import Data.RecipientGroup exposing (RecipientGroup)
import Date
import FilteringTable.Model as FTM
import FilteringTable.View exposing (uiTable)
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events exposing (onClick)
import Messages exposing (Msg(StoreMsg))
import Pages exposing (Page(ContactForm, GroupForm))
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import Pages.Forms.Group.Model exposing (initialGroupFormModel)
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(CancelSms))
import RemoteList as RL
import Time


-- Main view


view : FTM.Model -> Time.Time -> RL.RemoteList QueuedSms -> Html Msg
view tableModel currentTime sms =
    sms
        |> RL.filter (onlyFuture currentTime)
        |> uiTable tableHead tableModel smsRow


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "Queued By" ]
            , th [] [ text "Recipient" ]
            , th [] [ text "Group" ]
            , th [] [ text "Message" ]
            , th [] [ text "Scheduled Time" ]
            , th [] []
            ]
        ]


onlyFuture : Time.Time -> QueuedSms -> Bool
onlyFuture t sms =
    case sms.time_to_send of
        Just time_to_send ->
            t < Date.toTime time_to_send

        Nothing ->
            False


smsRow : QueuedSms -> Html Msg
smsRow sms =
    let
        className =
            case sms.failed of
                True ->
                    "negative"

                False ->
                    ""
    in
    tr [ A.class className ]
        [ td [] [ text sms.sent_by ]
        , td [] [ spaLink a [] [ text sms.recipient.full_name ] <| ContactForm initialContactFormModel <| Just sms.recipient.pk ]
        , td [] [ groupLink sms.recipient_group ]
        , td [] [ text sms.content ]
        , td [] [ text sms.time_to_send_formatted ]
        , td [ A.class "collapsing" ] [ cancelButton sms ]
        ]


groupLink : Maybe RecipientGroup -> Html Msg
groupLink group =
    case group of
        Nothing ->
            div [] []

        Just g ->
            spaLink a [] [ text g.name ] <| GroupForm initialGroupFormModel <| Just g.pk


cancelButton : QueuedSms -> Html Msg
cancelButton sms =
    a [ A.class "ui tiny grey button", onClick (StoreMsg (CancelSms sms.pk)) ] [ text "Cancel" ]
