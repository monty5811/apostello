module Updates.OutboundTable exposing (update)

import Actions exposing (determineRespCmd)
import Biu exposing (..)
import Helpers exposing (mergeItems, determineLoadingStatus, encodeBody)
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
            ( { model | loadingStatus = Finished }, biuLoadingFailed )


updateSms : OutboundTableModel -> ApostelloResponse SmsOutbound -> OutboundTableModel
updateSms model resp =
    { model | sms = mergeItems model.sms resp.results }
