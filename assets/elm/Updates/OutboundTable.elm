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
    case sms.time_sent of
        Just d ->
            Date.toTime d

        Nothing ->
            toFloat 1
