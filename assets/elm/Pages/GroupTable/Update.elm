module Pages.GroupTable.Update exposing (update)

import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup)
import Data.Store as Store
import Data.Store.Update exposing (optArchiveRecordWithPk)
import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (Msg(GroupTableMsg))
import Models exposing (CSRFToken, Model)
import Pages.GroupTable.Messages exposing (GroupTableMsg(ReceiveToggleGroupArchive, ToggleGroupArchive))
import Urls


update : GroupTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleGroupArchive isArchived pk ->
            ( { model | dataStore = optArchiveGroup model.dataStore pk }
            , [ toggleRecipientGroupArchive model.settings.csrftoken isArchived pk ]
            )

        ReceiveToggleGroupArchive (Ok _) ->
            ( model, [] )

        ReceiveToggleGroupArchive (Err _) ->
            handleNotSaved model


optArchiveGroup : Store.DataStore -> Int -> Store.DataStore
optArchiveGroup ds pk =
    { ds | groups = Store.map (optArchiveRecordWithPk pk) ds.groups }


toggleRecipientGroupArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientGroupArchive csrftoken isArchived pk =
    archivePost csrftoken (Urls.api_act_archive_group pk) isArchived decodeRecipientGroup
        |> Http.send (GroupTableMsg << ReceiveToggleGroupArchive)
