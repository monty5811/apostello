module Pages.SendAdhocForm.Update exposing (update)

import FilteringTable.Util as FT
import Helpers exposing (calculateSmsCost, toggleSelectedPk)
import Pages.SendAdhocForm.Messages exposing (SendAdhocMsg(..))
import Pages.SendAdhocForm.Model exposing (SendAdhocModel)


update : Float -> SendAdhocMsg -> SendAdhocModel -> SendAdhocModel
update twilioCost msg model =
    updateHelp msg model
        |> updateCost twilioCost


updateHelp : SendAdhocMsg -> SendAdhocModel -> SendAdhocModel
updateHelp msg model =
    case msg of
        -- form display:
        UpdateContent text ->
            { model | content = text }

        UpdateDate state maybeDate ->
            { model | date = maybeDate, datePickerState = state }

        ToggleSelectedContact pk ->
            { model | selectedContacts = toggleSelectedPk pk model.selectedContacts }

        UpdateAdhocFilter text ->
            { model | adhocFilter = FT.textToRegex text }


updateCost : Float -> SendAdhocModel -> SendAdhocModel
updateCost twilioCost model =
    case model.content of
        "" ->
            { model | cost = Nothing }

        c ->
            case model.selectedContacts |> List.length of
                0 ->
                    { model | cost = Nothing }

                n ->
                    { model
                        | cost = Just (calculateSmsCost (twilioCost * toFloat n) c)
                    }
