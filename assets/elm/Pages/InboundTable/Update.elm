module Pages.InboundTable.Update exposing (update)

import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound)
import Data.Store.Update exposing (updateSmsInbounds)
import DjangoSend exposing (post)
import Helpers exposing (handleNotSaved)
import Http
import Json.Encode as Encode
import Messages exposing (Msg(InboundTableMsg))
import Models exposing (CSRFToken, Model)
import Pages.InboundTable.Messages exposing (InboundTableMsg(..))
import Urls


update : InboundTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ReprocessSms pk ->
            ( model, [ reprocessSms model.settings.csrftoken pk ] )

        ReceiveReprocessSms (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] <| Just "dummy" }, [] )

        ReceiveReprocessSms (Err _) ->
            handleNotSaved model


reprocessSms : CSRFToken -> Int -> Cmd Msg
reprocessSms csrftoken pk =
    let
        body =
            [ ( "reingest", Encode.bool True ) ]
    in
    post csrftoken (Urls.api_act_reingest_sms pk) body decodeSmsInbound
        |> Http.send (InboundTableMsg << ReceiveReprocessSms)
