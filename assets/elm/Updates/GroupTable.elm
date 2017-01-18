module Updates.GroupTable exposing (update)

import Actions exposing (determineRespCmd)
import Biu exposing (..)
import Decoders exposing (recipientgroupDecoder)
import DjangoSend exposing (post)
import Helpers exposing (mergeItems, determineLoadingStatus, encodeBody)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : GroupTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadGroupTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , groupTable = updateGroups model.groupTable resp
              }
            , determineRespCmd GroupTable resp
            )

        LoadGroupTableResp (Err _) ->
            ( { model | loadingStatus = Finished }, biuLoadingFailed )

        ToggleGroupArchive isArchived pk ->
            ( { model | groupTable = optArchiveGroup model.groupTable pk }
            , toggleRecipientGroupArchive model.csrftoken isArchived pk
            )

        ReceiveToggleGroupArchive recipient ->
            ( model, Cmd.none )


updateGroups : GroupTableModel -> ApostelloResponse RecipientGroup -> GroupTableModel
updateGroups model resp =
    { model | groups = mergeItems model.groups resp.results }


optArchiveGroup : GroupTableModel -> Int -> GroupTableModel
optArchiveGroup model pk =
    { model | groups = List.filter (\r -> not (r.pk == pk)) model.groups }


toggleRecipientGroupArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleRecipientGroupArchive csrftoken isArchived pk =
    let
        url =
            "/api/v1/groups/" ++ (toString pk) ++ "?fields!members,nonmembers"

        body =
            encodeBody [ ( "archived", Encode.bool isArchived ) ]
    in
        post url body csrftoken recipientgroupDecoder
            |> Http.send (GroupTableMsg << ReceiveToggleGroupArchive)
