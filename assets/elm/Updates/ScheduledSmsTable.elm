module Updates.ScheduledSmsTable exposing (update, updateSms)

import Date
import Decoders exposing (decodeAlwaysTrue)
import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Urls exposing (..)


update : ScheduledSmsTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CancelSms pk ->
            ( { model | scheduledSmsTable = optCancelSms model.scheduledSmsTable pk }, cancelSms model.csrftoken pk )

        ReceiveCancelSms (Ok _) ->
            ( model, Cmd.none )

        ReceiveCancelSms (Err _) ->
            handleNotSaved model


updateSms : ScheduledSmsTableModel -> List QueuedSms -> ScheduledSmsTableModel
updateSms model newSms =
    { model
        | sms =
            mergeItems model.sms newSms
                |> List.sortBy compareByT2S
    }


compareByT2S : { a | time_to_send : Maybe Date.Date } -> Float
compareByT2S sms =
    case sms.time_to_send of
        Just d ->
            Date.toTime d

        Nothing ->
            toFloat 1


optCancelSms : ScheduledSmsTableModel -> Int -> ScheduledSmsTableModel
optCancelSms model pk =
    { model | sms = List.filter (\r -> not (r.pk == pk)) model.sms }


cancelSms : CSRFToken -> Int -> Cmd Msg
cancelSms csrftoken pk =
    let
        url =
            queuedSmsUrl pk

        body =
            [ ( "cancel_sms", Encode.bool True ) ]
    in
        post csrftoken url body decodeAlwaysTrue
            |> Http.send (ScheduledSmsTableMsg << ReceiveCancelSms)
