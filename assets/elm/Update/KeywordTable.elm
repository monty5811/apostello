module Update.KeywordTable exposing (update)

import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (..)
import Models exposing (Model, DataStore, CSRFToken)
import Models.Apostello exposing (Keyword, decodeKeyword)
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


optArchiveKeyword : DataStore -> String -> DataStore
optArchiveKeyword ds k =
    { ds | keywords = optArchiveKeywordHelper ds.keywords k }


optArchiveKeywordHelper : List { a | keyword : String, is_archived : Bool } -> String -> List { a | keyword : String, is_archived : Bool }
optArchiveKeywordHelper recs k =
    recs
        |> List.map (toggleIsArchived k)


toggleIsArchived : String -> { a | keyword : String, is_archived : Bool } -> { a | keyword : String, is_archived : Bool }
toggleIsArchived k rec =
    case k == rec.keyword of
        True ->
            { rec | is_archived = not rec.is_archived }

        False ->
            rec


toggleKeywordArchive : CSRFToken -> Bool -> String -> Cmd Msg
toggleKeywordArchive csrftoken isArchived k =
    archivePost csrftoken (Urls.keyword k) isArchived decodeKeyword
        |> Http.send (KeywordTableMsg << ReceiveToggleKeywordArchive)
