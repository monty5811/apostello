module Updates.GroupComposer exposing (update)

import Biu exposing (..)
import Helpers exposing (mergeItems, determineLoadingStatus, encodeBody)
import Actions exposing (determineRespCmd)
import Dict
import Messages exposing (..)
import Models exposing (..)


update : GroupComposerMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadGroupComposerResp (Ok resp) ->
            ( { model
                | loadingStatus = Finished
                , groupComposer = updateGroups resp model.groupComposer
              }
            , determineRespCmd GroupComposer resp
            )

        LoadGroupComposerResp (Err _) ->
            ( { model | loadingStatus = Finished }, biuLoadingFailed )

        UpdateQueryString text ->
            ( { model | groupComposer = updateQueryString text model.groupComposer }, Cmd.none )


updateGroups : ApostelloResponse RecipientGroup -> GroupComposerModel -> GroupComposerModel
updateGroups resp model =
    let
        newGroups =
            mergeItems model.groups resp.results
    in
        { model
            | groups = newGroups
            , people = (collectPeople newGroups)
        }


updateQueryString : String -> GroupComposerModel -> GroupComposerModel
updateQueryString string model =
    { model | query = Just string }



-- Collect people pks from groups into single list


collectPeople : Groups -> PeopleSimple
collectPeople groups =
    let
        people =
            groups
                |> List.concatMap (\x -> x.members)
                |> List.map (\x -> ( x.pk, x ))
    in
        Dict.fromList people
            |> Dict.toList
            |> List.map (\x -> Tuple.second x)
