module Updates.RecipientTable exposing (update, updateRecipients)

import Decoders exposing (recipientDecoder)
import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (..)
import Models exposing (..)
import Urls exposing (..)


update : RecipientTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleRecipientArchive isArchived pk ->
            ( { model | recipientTable = optRemoveRecipient model.recipientTable pk }
            , toggleRecipientArchive model.csrftoken isArchived pk
            )

        ReceiveRecipientToggleArchive (Ok _) ->
            ( model, Cmd.none )

        ReceiveRecipientToggleArchive (Err _) ->
            handleNotSaved model


updateRecipients : RecipientTableModel -> List Recipient -> RecipientTableModel
updateRecipients model newRecipients =
    { model
        | recipients =
            mergeItems model.recipients newRecipients
                |> List.sortBy .last_name
    }


optRemoveRecipient : RecipientTableModel -> Int -> RecipientTableModel
optRemoveRecipient model pk =
    { model | recipients = List.filter (\r -> not (r.pk == pk)) model.recipients }


toggleRecipientArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientArchive csrftoken isArchived pk =
    archivePost csrftoken (recipientUrl pk) isArchived recipientDecoder
        |> Http.send (RecipientTableMsg << ReceiveRecipientToggleArchive)
