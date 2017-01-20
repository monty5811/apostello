module Views.ScheduledSmsTable exposing (view)

import Date
import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Time
import Views.FilteringTable exposing (filteringTable)


-- Main view


view : Regex.Regex -> Time.Time -> ScheduledSmsTableModel -> Html Msg
view filterRegex currentTime model =
    let
        head =
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

        sms =
            model.sms
                |> List.filter (onlyFuture currentTime)
    in
        filteringTable filterRegex smsRow sms head "ui table"


onlyFuture : Time.Time -> QueuedSms -> Bool
onlyFuture t sms =
    t < (Date.toTime sms.time_to_send)


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
        tr [ class className ]
            [ td [] [ text sms.sent_by ]
            , td [] [ a [ href sms.recipient.url ] [ text sms.recipient.full_name ] ]
            , td [] [ groupLink sms.recipient_group ]
            , td [] [ text sms.content ]
            , td [] [ text sms.time_to_send_formatted ]
            , td [ class "collapsing" ] [ cancelButton sms ]
            ]


groupLink : Maybe RecipientGroup -> Html Msg
groupLink group =
    case group of
        Nothing ->
            div [] []

        Just g ->
            a [ href g.url ] [ text g.name ]


cancelButton : QueuedSms -> Html Msg
cancelButton sms =
    a [ class "ui tiny grey button", onClick (ScheduledSmsTableMsg (CancelSms sms.pk)) ] [ text "Cancel" ]
