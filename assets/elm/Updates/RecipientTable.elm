module Updates.RecipientTable exposing (update)

import Actions exposing (determineRespCmd)
import Biu exposing (..)
import Decoders exposing (recipientDecoder)
import DjangoSend exposing (post)
import Helpers exposing (mergeItems, determineLoadingStatus, encodeBody)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : RecipientTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadRecipientTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , recipientTable = updateRecipients model.recipientTable resp.results
              }
            , determineRespCmd RecipientTable resp
            )

        LoadRecipientTableResp (Err _) ->
            ( { model | loadingStatus = Finished }, biuLoadingFailed )

        ToggleRecipientArchive isArchived pk ->
            ( { model | recipientTable = optRemoveRecipient model.recipientTable pk }
            , toggleRecipientArchive model.csrftoken isArchived pk
            )

        ReceiveRecipientToggleArchive (Ok _) ->
            ( model, Cmd.none )

        ReceiveRecipientToggleArchive (Err _) ->
            ( model, biuNotSaved )


updateRecipients : RecipientTableModel -> List Recipient -> RecipientTableModel
updateRecipients model newRecipients =
    { model | recipients = mergeItems model.recipients newRecipients }


optRemoveRecipient : RecipientTableModel -> Int -> RecipientTableModel
optRemoveRecipient model pk =
    { model | recipients = List.filter (\r -> not (r.pk == pk)) model.recipients }


toggleRecipientArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientArchive csrftoken isArchived pk =
    let
        url =
            "/api/v1/recipients/" ++ (toString pk)

        body =
            encodeBody [ ( "archived", Encode.bool isArchived ) ]
    in
        post url body csrftoken recipientDecoder
            |> Http.send (RecipientTableMsg << ReceiveRecipientToggleArchive)
