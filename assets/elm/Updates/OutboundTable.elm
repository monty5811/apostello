module Updates.OutboundTable exposing (updateModel)

import Date
import Helpers exposing (..)
import Models exposing (..)


updateModel : OutboundTableModel -> List SmsOutbound -> OutboundTableModel
updateModel model sms =
    { model
        | sms =
            mergeItems model.sms sms
                |> List.sortBy compareByTS
                |> List.reverse
    }


compareByTS : SmsOutbound -> Float
compareByTS sms =
    let
        date =
            Date.fromString sms.time_sent
    in
        case date of
            Ok d ->
                Date.toTime d

            Err _ ->
                toFloat 1
