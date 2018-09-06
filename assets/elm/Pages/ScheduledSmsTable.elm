module Pages.ScheduledSmsTable exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (QueuedSms, Recipient, RecipientGroup)
import Date
import FilteringTable as FT
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onClick)
import RemoteList as RL
import Time


-- Model


type alias Model =
    { tableModel : FT.Model
    }


initialModel : Model
initialModel =
    { tableModel = FT.initialModel }



-- Update


type Msg
    = TableMsg FT.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        TableMsg tableMsg ->
            { model | tableModel = FT.update tableMsg model.tableModel }



-- Main view


type alias Props msg =
    { currentTime : Time.Time
    , tableMsg : FT.Msg -> msg
    , sms : RL.RemoteList QueuedSms
    , cancelSms : Int -> msg
    , groupLink : RecipientGroup -> Html msg
    , contactLink : Recipient -> Html msg
    }


view : Props msg -> Model -> Html msg
view props { tableModel } =
    props.sms
        |> RL.filter (onlyFuture props.currentTime)
        |> FT.defaultTable { top = props.tableMsg } tableHead tableModel (smsRow props)


tableHead : FT.Head
tableHead =
    FT.Head
        [ "Queued By"
        , "Recipient"
        , "Group"
        , "Message"
        , "Scheduled Time"
        , ""
        ]


onlyFuture : Time.Time -> QueuedSms -> Bool
onlyFuture t sms =
    case sms.time_to_send of
        Just time_to_send ->
            t < Date.toTime time_to_send

        Nothing ->
            False


smsRow : Props msg -> QueuedSms -> FT.Row msg
smsRow props sms =
    let
        style =
            case sms.failed of
                True ->
                    [ Css.bg_red ]

                False ->
                    []
    in
    FT.Row
        style
        [ FT.Cell [] [ Html.text sms.sent_by ]
        , FT.Cell [] [ props.contactLink sms.recipient ]
        , FT.Cell [] [ groupLink props sms.recipient_group ]
        , FT.Cell [] [ Html.text sms.content ]
        , FT.Cell [ Css.collapsing ] [ Html.text sms.time_to_send_formatted ]
        , FT.Cell [ Css.collapsing ] [ cancelButton props sms ]
        ]
        (toString sms.pk)


groupLink : Props msg -> Maybe RecipientGroup -> Html msg
groupLink props group =
    case group of
        Nothing ->
            Html.div [] []

        Just g ->
            props.groupLink g


cancelButton : Props msg -> QueuedSms -> Html msg
cancelButton props sms =
    Html.a
        [ onClick (props.cancelSms sms.pk)
        , A.id "cancelSmsButton"
        , Css.btn
        , Css.btn_red
        ]
        [ Html.text "Cancel" ]
