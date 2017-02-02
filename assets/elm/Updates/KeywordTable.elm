module Updates.KeywordTable exposing (update, updateKeywords)

import Decoders exposing (keywordDecoder)
import DjangoSend exposing (archivePost)
import Helpers exposing (..)
import Http
import Messages exposing (..)
import Models exposing (..)
import Urls exposing (..)


update : KeywordTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleKeywordArchive isArchived pk ->
            ( { model
                | keywordTable = optArchiveKeyword model.keywordTable pk
              }
            , toggleKeywordArchive model.csrftoken isArchived pk
            )

        ReceiveToggleKeywordArchive (Ok _) ->
            ( model, Cmd.none )

        ReceiveToggleKeywordArchive (Err _) ->
            handleNotSaved model


updateKeywords : KeywordTableModel -> List Keyword -> KeywordTableModel
updateKeywords model keywords =
    { model | keywords = mergeItems model.keywords keywords |> List.sortBy .keyword }


optArchiveKeyword : KeywordTableModel -> Int -> KeywordTableModel
optArchiveKeyword model pk =
    { model | keywords = List.filter (\r -> not (r.pk == pk)) model.keywords }


toggleKeywordArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleKeywordArchive csrftoken isArchived pk =
    archivePost csrftoken (keywordUrl pk) isArchived keywordDecoder
        |> Http.send (KeywordTableMsg << ReceiveToggleKeywordArchive)
