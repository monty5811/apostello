module Updates.ScheduledSmsTable exposing (update)

import Actions exposing (determineRespCmd)
import Decoders exposing (decodeAlwaysTrue)
import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : ScheduledSmsTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadScheduledSmsTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , scheduledSmsTable = updateSms model.scheduledSmsTable resp.results
              }
            , determineRespCmd InboundTable resp
            )

        LoadScheduledSmsTableResp (Err _) ->
            handleLoadingFailed model

        CancelSms pk ->
            ( { model | scheduledSmsTable = optCancelSms model.scheduledSmsTable pk }, cancelSms model.csrftoken pk )

        ReceiveCancelSms (Ok _) ->
            ( model, Cmd.none )

        ReceiveCancelSms (Err _) ->
            handleNotSaved model


updateSms : ScheduledSmsTableModel -> List QueuedSms -> ScheduledSmsTableModel
updateSms model newSms =
    { model | sms = mergeItems model.sms newSms }


optCancelSms : ScheduledSmsTableModel -> Int -> ScheduledSmsTableModel
optCancelSms model pk =
    { model | sms = List.filter (\r -> not (r.pk == pk)) model.sms }


cancelSms : CSRFToken -> Int -> Cmd Msg
cancelSms csrftoken pk =
    let
        url =
            "/api/v1/queued/sms/" ++ (toString pk)

        body =
            encodeBody [ ( "cancel_sms", Encode.bool True ) ]
    in
        post url body csrftoken decodeAlwaysTrue
            |> Http.send (ScheduledSmsTableMsg << ReceiveCancelSms)
