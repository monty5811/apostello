module Pages.ScheduledSmsTable.View exposing (view)

import Data.QueuedSms exposing (QueuedSms)
import Data.RecipientGroup exposing (RecipientGroup)
import Data.Store as Store
import Date
import FilteringTable exposing (uiTable)
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events exposing (onClick)
import Messages exposing (Msg(ScheduledSmsTableMsg))
import Pages exposing (Page(ContactForm, GroupForm))
import Pages.ContactForm.Model exposing (initialContactFormModel)
import Pages.GroupForm.Model exposing (initialGroupFormModel)
import Pages.ScheduledSmsTable.Messages exposing (ScheduledSmsTableMsg(CancelSms))
import Regex
import Route exposing (spaLink)
import Time


-- Main view


view : Regex.Regex -> Time.Time -> Store.RemoteList QueuedSms -> Html Msg
view filterRegex currentTime sms =
    sms
        |> Store.filter (onlyFuture currentTime)
        |> uiTable tableHead filterRegex smsRow


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
    a [ A.class "ui tiny grey button", onClick (ScheduledSmsTableMsg (CancelSms sms.pk)) ] [ text "Cancel" ]
