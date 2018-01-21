module Pages.ScheduledSmsTable exposing (view)

import Data exposing (QueuedSms, Recipient, RecipientGroup)
import Date
import FilteringTable as FT
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events exposing (onClick)
import RemoteList as RL
import Time


-- Main view


type alias Props msg =
    { currentTime : Time.Time
    , tableModel : FT.Model
    , tableMsg : FT.Msg -> msg
    , sms : RL.RemoteList QueuedSms
    , cancelSms : Int -> msg
    , groupLink : RecipientGroup -> Html msg
    , contactLink : Recipient -> Html msg
    }


view : Props msg -> Html msg
view props =
    props.sms
        |> RL.filter (onlyFuture props.currentTime)
        |> FT.defaultTable { top = props.tableMsg } tableHead props.tableModel (smsRow props)


tableHead : Html msg
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


smsRow : Props msg -> QueuedSms -> ( String, Html msg )
smsRow props sms =
    let
        style =
            case sms.failed of
                True ->
                    [ ( "background", "var(--color-red)" ) ]

                False ->
                    []
    in
    ( toString sms.pk
    , tr [ A.style style ]
        [ td [] [ text sms.sent_by ]
        , td [] [ props.contactLink sms.recipient ]
        , td [] [ groupLink props sms.recipient_group ]
        , td [] [ text sms.content ]
        , td [] [ text sms.time_to_send_formatted ]
        , td [] [ cancelButton props sms ]
        ]
    )


groupLink : Props msg -> Maybe RecipientGroup -> Html msg
groupLink props group =
    case group of
        Nothing ->
            div [] []

        Just g ->
            props.groupLink g


cancelButton : Props msg -> QueuedSms -> Html msg
cancelButton props sms =
    a
        [ A.class "button button-danger"
        , onClick (props.cancelSms sms.pk)
        , A.id "cancelSmsButton"
        ]
        [ text "Cancel" ]
