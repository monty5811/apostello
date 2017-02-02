module Updates.GroupComposer exposing (update, updateGroups)

import Helpers exposing (..)
import Dict
import Messages exposing (..)
import Models exposing (..)


update : GroupComposerMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateQueryString text ->
            ( { model | groupComposer = updateQueryString text model.groupComposer }, Cmd.none )


updateGroups : GroupComposerModel -> List RecipientGroup -> GroupComposerModel
updateGroups model groups =
    let
        newGroups =
            mergeItems model.groups groups
    in
        { model
            | groups = newGroups |> List.sortBy .name
            , people = (collectPeople newGroups) |> List.sortBy .full_name
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
