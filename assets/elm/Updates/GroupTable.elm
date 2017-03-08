module Updates.GroupTable exposing (update)

import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (..)
import Models exposing (..)
import Urls
import Updates.DataStore exposing (optArchiveRecordWithPk)


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


optArchiveGroup : DataStore -> Int -> DataStore
optArchiveGroup ds pk =
    { ds | groups = optArchiveRecordWithPk ds.groups pk }


toggleRecipientGroupArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientGroupArchive csrftoken isArchived pk =
    archivePost csrftoken (Urls.group pk) isArchived recipientgroupDecoder
        |> Http.send (GroupTableMsg << ReceiveToggleGroupArchive)
