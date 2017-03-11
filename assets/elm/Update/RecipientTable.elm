module Update.RecipientTable exposing (update)

import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (..)
import Models exposing (Model, DataStore, CSRFToken)
import Models.Apostello exposing (Recipient, decodeRecipient)
import Urls
import Update.DataStore exposing (optArchiveRecordWithPk)


update : RecipientTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleRecipientArchive isArchived pk ->
            ( { model | dataStore = optRemoveRecipient model.dataStore pk }
            , [ toggleRecipientArchive model.settings.csrftoken isArchived pk ]
            )

        ReceiveRecipientToggleArchive (Ok _) ->
            ( model, [] )

        ReceiveRecipientToggleArchive (Err _) ->
            handleNotSaved model


optRemoveRecipient : DataStore -> Int -> DataStore
optRemoveRecipient ds pk =
    { ds | recipients = optArchiveRecordWithPk ds.recipients pk }


toggleRecipientArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientArchive csrftoken isArchived pk =
    archivePost csrftoken (Urls.recipient pk) isArchived decodeRecipient
        |> Http.send (RecipientTableMsg << ReceiveRecipientToggleArchive)
