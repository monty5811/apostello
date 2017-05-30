module Pages.ScheduledSmsTable.Update exposing (update)

import Data.Store as Store
import DjangoSend exposing (post)
import Helpers exposing (decodeAlwaysTrue, handleNotSaved)
import Http
import Json.Encode as Encode
import Messages exposing (Msg(ScheduledSmsTableMsg))
import Models exposing (..)
import Pages.ScheduledSmsTable.Messages exposing (ScheduledSmsTableMsg(CancelSms, ReceiveCancelSms))
import Urls


update : ScheduledSmsTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        CancelSms pk ->
            ( { model | dataStore = optCancelSms model.dataStore pk }, [ cancelSms model.settings.csrftoken pk ] )

        ReceiveCancelSms (Ok _) ->
            ( model, [] )

        ReceiveCancelSms (Err _) ->
            handleNotSaved model


optCancelSms : Store.DataStore -> Int -> Store.DataStore
optCancelSms ds pk =
    { ds | queuedSms = Store.filter (\r -> not (r.pk == pk)) ds.queuedSms }


cancelSms : CSRFToken -> Int -> Cmd Msg
cancelSms csrftoken pk =
    let
        url =
            Urls.api_act_cancel_queued_sms pk

        body =
            [ ( "cancel_sms", Encode.bool True ) ]
    in
    post csrftoken url body decodeAlwaysTrue
        |> Http.send (ScheduledSmsTableMsg << ReceiveCancelSms)
