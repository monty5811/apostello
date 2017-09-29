module Pages.ScheduledSmsTable exposing (view)

import Data exposing (QueuedSms, RecipientGroup)
import Date
import FilteringTable as FT
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events exposing (onClick)
import Messages exposing (Msg(StoreMsg))
import Pages exposing (Page(ContactForm, GroupForm))
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import Pages.Forms.Group.Model exposing (initialGroupFormModel)
import RemoteList as RL
import Rocket exposing ((=>))
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(CancelSms))
import Time


-- Main view


view : FT.Model -> Time.Time -> RL.RemoteList QueuedSms -> Html Msg
view tableModel currentTime sms =
    sms
        |> RL.filter (onlyFuture currentTime)
        |> FT.defaultTable tableHead tableModel smsRow


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


smsRow : QueuedSms -> ( String, Html Msg )
smsRow sms =
    let
        style =
            case sms.failed of
                True ->
                    [ "background" => "var(--color-red)" ]

                False ->
                    []
    in
    ( toString sms.pk
    , tr [ A.style style ]
        [ td [] [ text sms.sent_by ]
        , td [] [ spaLink a [] [ text sms.recipient.full_name ] <| ContactForm initialContactFormModel <| Just sms.recipient.pk ]
        , td [] [ groupLink sms.recipient_group ]
        , td [] [ text sms.content ]
        , td [] [ text sms.time_to_send_formatted ]
        , td [] [ cancelButton sms ]
        ]
    )


groupLink : Maybe RecipientGroup -> Html Msg
groupLink group =
    case group of
        Nothing ->
            div [] []

        Just g ->
            spaLink a [] [ text g.name ] <| GroupForm initialGroupFormModel <| Just g.pk


cancelButton : QueuedSms -> Html Msg
cancelButton sms =
    a
        [ A.class "button button-danger"
        , onClick (StoreMsg (CancelSms sms.pk))
        , A.id "cancelSmsButton"
        ]
        [ text "Cancel" ]
