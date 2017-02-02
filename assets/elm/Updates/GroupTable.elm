module Updates.GroupTable exposing (update, updateGroups)

import Decoders exposing (recipientgroupDecoder)
import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (..)
import Models exposing (..)
import Urls exposing (..)


update : GroupTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleGroupArchive isArchived pk ->
            ( { model | groupTable = optArchiveGroup model.groupTable pk }
            , toggleRecipientGroupArchive model.csrftoken isArchived pk
            )

        ReceiveToggleGroupArchive (Ok _) ->
            ( model, Cmd.none )

        ReceiveToggleGroupArchive (Err _) ->
            handleNotSaved model


updateGroups : GroupTableModel -> List RecipientGroup -> GroupTableModel
updateGroups model groups =
    { model
        | groups =
            mergeItems model.groups groups
                |> List.sortBy .name
    }


optArchiveGroup : GroupTableModel -> Int -> GroupTableModel
optArchiveGroup model pk =
    { model | groups = List.filter (\r -> not (r.pk == pk)) model.groups }


toggleRecipientGroupArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientGroupArchive csrftoken isArchived pk =
    archivePost csrftoken (groupsUrl_quick pk) isArchived recipientgroupDecoder
        |> Http.send (GroupTableMsg << ReceiveToggleGroupArchive)
