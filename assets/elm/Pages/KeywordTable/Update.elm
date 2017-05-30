module Pages.KeywordTable.Update exposing (update)

import Data.Keyword exposing (Keyword, decodeKeyword)
import Data.Store as Store
import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (Msg(KeywordTableMsg))
import Models exposing (CSRFToken, Model)
import Pages.KeywordTable.Messages exposing (KeywordTableMsg(ReceiveToggleKeywordArchive, ToggleKeywordArchive))
import Urls


update : KeywordTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleKeywordArchive isArchived k ->
            ( { model
                | dataStore = optArchiveKeyword model.dataStore k
              }
            , [ toggleKeywordArchive model.settings.csrftoken isArchived k ]
            )

        ReceiveToggleKeywordArchive (Ok _) ->
            ( model, [] )

        ReceiveToggleKeywordArchive (Err _) ->
            handleNotSaved model


optArchiveKeyword : Store.DataStore -> String -> Store.DataStore
optArchiveKeyword ds k =
    { ds | keywords = Store.map (optArchiveKeywordHelper k) ds.keywords }


optArchiveKeywordHelper : String -> { a | keyword : String, is_archived : Bool } -> { a | keyword : String, is_archived : Bool }
optArchiveKeywordHelper k =
    toggleIsArchived k


toggleIsArchived : String -> { a | keyword : String, is_archived : Bool } -> { a | keyword : String, is_archived : Bool }
toggleIsArchived k rec =
    case k == rec.keyword of
        True ->
            { rec | is_archived = not rec.is_archived }

        False ->
            rec


toggleKeywordArchive : CSRFToken -> Bool -> String -> Cmd Msg
toggleKeywordArchive csrftoken isArchived k =
    archivePost csrftoken (Urls.api_act_archive_keyword k) isArchived decodeKeyword
        |> Http.send (KeywordTableMsg << ReceiveToggleKeywordArchive)
