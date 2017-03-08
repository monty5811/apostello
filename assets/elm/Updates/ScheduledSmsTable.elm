module Updates.ScheduledSmsTable exposing (update)

import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
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


optCancelSms : DataStore -> Int -> DataStore
optCancelSms ds pk =
    { ds | queuedSms = List.filter (\r -> not (r.pk == pk)) ds.queuedSms }


cancelSms : CSRFToken -> Int -> Cmd Msg
cancelSms csrftoken pk =
    let
        url =
            Urls.queuedSms pk

        body =
            [ ( "cancel_sms", Encode.bool True ) ]
    in
        post csrftoken url body decodeAlwaysTrue
            |> Http.send (ScheduledSmsTableMsg << ReceiveCancelSms)
