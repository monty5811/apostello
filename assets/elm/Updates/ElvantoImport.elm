module Updates.ElvantoImport exposing (update)

import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Updates.Notification exposing (createInfoNotification, createSuccessNotification)
import Urls
import Updates.DataStore exposing (updateElvantoGroups)


update : ElvantoMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleGroupSync group ->
            ( { model | dataStore = optToggleGroup group model.dataStore }
            , [ toggleElvantoGroupSync model.settings.csrftoken group ]
            )

        ReceiveToggleGroupSync (Ok group) ->
            ( { model | dataStore = updateElvantoGroups model.dataStore [ group ] }
            , []
            )

        ReceiveToggleGroupSync (Err _) ->
            handleNotSaved model

        PullGroups ->
            ( createInfoNotification model "Groups are being imported, it may take a couple of minutes"
            , [ buttonReq model.settings.csrftoken Urls.elvantoPullGroups ]
            )

        FetchGroups ->
            ( createSuccessNotification model "Groups are being fetched, it may take a couple of minutes"
            , [ buttonReq model.settings.csrftoken Urls.elvantoFetchGroups ]
            )

        ReceiveButtonResp (Ok _) ->
            ( model, [] )

        ReceiveButtonResp (Err _) ->
            handleNotSaved model


buttonReq : CSRFToken -> String -> Cmd Msg
buttonReq csrftoken url =
    post csrftoken url [] (Decode.succeed True)
        |> Http.send (ElvantoMsg << ReceiveButtonResp)


toggleElvantoGroupSync : CSRFToken -> ElvantoGroup -> Cmd Msg
toggleElvantoGroupSync csrftoken group =
    let
        url =
            Urls.elvantoGroup group.pk

        body =
            [ ( "sync", Encode.bool group.sync ) ]
    in
        post csrftoken url body elvantogroupDecoder
            |> Http.send (ElvantoMsg << ReceiveToggleGroupSync)


optToggleGroup : ElvantoGroup -> DataStore -> DataStore
optToggleGroup group ds =
    { ds | elvantoGroups = List.map (toggleGroupSync group.pk) ds.elvantoGroups }


toggleGroupSync : Int -> ElvantoGroup -> ElvantoGroup
toggleGroupSync pk group =
    if pk == group.pk then
        { group | sync = (not group.sync) }
    else
        group
