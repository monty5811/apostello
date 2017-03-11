module Views.ScheduledSmsTable exposing (view)

import Date
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Time
import Views.FilteringTable exposing (uiTable)


-- Main view


view : Regex.Regex -> Time.Time -> List QueuedSms -> Html Msg
view filterRegex currentTime sms =
    sms
        |> List.filter (onlyFuture currentTime)
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
