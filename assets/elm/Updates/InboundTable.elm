module Updates.InboundTable exposing (update, updateSms)

import Decoders exposing (smsinboundDecoder)
import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Urls exposing (..)


update : InboundTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReprocessSms pk ->
            ( model, reprocessSms model.csrftoken pk )

        ReceiveReprocessSms (Ok sms) ->
            ( { model | inboundTable = updateSms model.inboundTable [ sms ] }, Cmd.none )

        ReceiveReprocessSms (Err _) ->
            handleNotSaved model


updateSms : InboundTableModel -> SmsInbounds -> InboundTableModel
updateSms model newSms =
    { model
        | sms =
            mergeItems model.sms newSms
                |> sortByTimeReceived
    }


reprocessSms : CSRFToken -> Int -> Cmd Msg
reprocessSms csrftoken pk =
    let
        url =
            smsInboundUrl pk

        body =
            [ ( "reingest", Encode.bool True ) ]
    in
        post csrftoken url body smsinboundDecoder
            |> Http.send (InboundTableMsg << ReceiveReprocessSms)
