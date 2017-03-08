module Updates.InboundTable exposing (update)

import DjangoSend exposing (post)
import Helpers exposing (handleNotSaved)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Updates.DataStore exposing (updateSmsInbounds)
import Urls


update : InboundTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ReprocessSms pk ->
            ( model, [ reprocessSms model.settings.csrftoken pk ] )

        ReceiveReprocessSms (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] }, [] )

        ReceiveReprocessSms (Err _) ->
            handleNotSaved model


reprocessSms : CSRFToken -> Int -> Cmd Msg
reprocessSms csrftoken pk =
    let
        body =
            [ ( "reingest", Encode.bool True ) ]
    in
        post csrftoken (Urls.smsInbound pk) body smsinboundDecoder
            |> Http.send (InboundTableMsg << ReceiveReprocessSms)
