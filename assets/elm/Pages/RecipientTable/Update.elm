module Pages.RecipientTable.Update exposing (update)

import Data.Recipient exposing (Recipient, decodeRecipient)
import Data.Store as Store
import Data.Store.Update exposing (optArchiveRecordWithPk)
import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (Msg(RecipientTableMsg))
import Models exposing (CSRFToken, Model)
import Pages.RecipientTable.Messages exposing (RecipientTableMsg(ReceiveRecipientToggleArchive, ToggleRecipientArchive))
import Urls


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


optRemoveRecipient : Store.DataStore -> Int -> Store.DataStore
optRemoveRecipient ds pk =
    { ds | recipients = Store.map (optArchiveRecordWithPk pk) ds.recipients }


toggleRecipientArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientArchive csrftoken isArchived pk =
    archivePost csrftoken (Urls.api_act_archive_recipient pk) isArchived decodeRecipient
        |> Http.send (RecipientTableMsg << ReceiveRecipientToggleArchive)
