module Pages.SendGroupForm.Update exposing (..)

import Data.RecipientGroup exposing (RecipientGroup, nullGroup)
import FilteringTable as FT
import Helpers exposing (calculateSmsCost)
import Pages.SendGroupForm.Messages exposing (SendGroupMsg(SelectGroup, UpdateGroupFilter, UpdateSGContent, UpdateSGDate))
import Pages.SendGroupForm.Model exposing (SendGroupModel)


update : List RecipientGroup -> SendGroupMsg -> SendGroupModel -> SendGroupModel
update groups msg model =
    updateHelp msg model
        |> updateCost groups


updateHelp : SendGroupMsg -> SendGroupModel -> SendGroupModel
updateHelp msg model =
    case msg of
        UpdateSGContent text ->
            { model | content = text }

        UpdateSGDate state maybeDate ->
            { model | date = maybeDate, datePickerState = state }

        SelectGroup pk ->
            { model | selectedPk = Just pk }

        UpdateGroupFilter text ->
            { model | groupFilter = FT.textToRegex text }


updateCost : List RecipientGroup -> SendGroupModel -> SendGroupModel
updateCost groups model =
    case model.content of
        "" ->
            { model | cost = Nothing }

        c ->
            case model.selectedPk of
                Nothing ->
                    { model | cost = Nothing }

                Just pk ->
                    let
                        groupCost =
                            groups
                                |> List.filter (\x -> x.pk == pk)
                                |> List.head
                                |> Maybe.withDefault nullGroup
                                |> .cost
                    in
                    { model | cost = Just (calculateSmsCost groupCost c) }
