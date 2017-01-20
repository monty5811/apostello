module Updates.OutboundTable exposing (update)

import Actions exposing (determineRespCmd)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)


update : OutboundTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadOutboundTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , outboundTable = updateSms model.outboundTable resp
              }
            , determineRespCmd OutboundTable resp
            )

        LoadOutboundTableResp (Err _) ->
            handleLoadingFailed model


updateSms : OutboundTableModel -> ApostelloResponse SmsOutbound -> OutboundTableModel
updateSms model resp =
    { model | sms = mergeItems model.sms resp.results }
