module Updates.GroupTable exposing (update)

import Actions exposing (determineRespCmd)
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
        LoadGroupTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , groupTable = updateGroups model.groupTable resp
              }
            , determineRespCmd GroupTable resp
            )

        LoadGroupTableResp (Err _) ->
            handleLoadingFailed model

        ToggleGroupArchive isArchived pk ->
            ( { model | groupTable = optArchiveGroup model.groupTable pk }
            , toggleRecipientGroupArchive model.csrftoken isArchived pk
            )

        ReceiveToggleGroupArchive (Ok _) ->
            ( model, Cmd.none )

        ReceiveToggleGroupArchive (Err _) ->
            handleNotSaved model


updateGroups : GroupTableModel -> ApostelloResponse RecipientGroup -> GroupTableModel
updateGroups model resp =
    { model
        | groups =
            mergeItems model.groups resp.results
                |> List.sortBy .name
    }


optArchiveGroup : GroupTableModel -> Int -> GroupTableModel
optArchiveGroup model pk =
    { model | groups = List.filter (\r -> not (r.pk == pk)) model.groups }


toggleRecipientGroupArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientGroupArchive csrftoken isArchived pk =
    archivePost csrftoken (groupsUrl_quick pk) isArchived recipientgroupDecoder
        |> Http.send (GroupTableMsg << ReceiveToggleGroupArchive)
