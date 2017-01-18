module Updates.KeywordTable exposing (update)

import Biu exposing (..)
import Helpers exposing (mergeItems, determineLoadingStatus, encodeBody)
import Actions exposing (determineRespCmd)
import Decoders exposing (keywordDecoder)
import DjangoSend exposing (post)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : KeywordTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadKeywordTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , keywordTable = updateKeywords model.keywordTable resp
              }
            , determineRespCmd KeywordTable resp
            )

        LoadKeywordTableResp (Err _) ->
            ( { model | loadingStatus = Finished }, biuLoadingFailed )

        ToggleKeywordArchive isArchived pk ->
            ( { model
                | keywordTable = optArchiveKeyword model.keywordTable pk
              }
            , toggleKeywordArchive model.csrftoken isArchived pk
            )

        ReceiveToggleKeywordArchive keyword ->
            ( model, Cmd.none )


optArchiveKeyword : KeywordTableModel -> Int -> KeywordTableModel
optArchiveKeyword model pk =
    { model | keywords = List.filter (\r -> not (r.pk == pk)) model.keywords }


updateKeywords : KeywordTableModel -> ApostelloResponse Keyword -> KeywordTableModel
updateKeywords model resp =
    { model | keywords = mergeItems model.keywords resp.results }


toggleKeywordArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleKeywordArchive csrftoken isArchived pk =
    let
        url =
            "/api/v1/keywords/" ++ (toString pk)

        body =
            encodeBody [ ( "archived", Encode.bool isArchived ) ]
    in
        post url body csrftoken keywordDecoder
            |> Http.send (KeywordTableMsg << ReceiveToggleKeywordArchive)
