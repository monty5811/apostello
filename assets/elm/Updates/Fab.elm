port module Updates.Fab exposing (update)

import Decoders exposing (decodeAlwaysTrue)
import DjangoSend exposing (post)
import Helpers exposing (encodeBody)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : FabMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArchiveItem ->
            case model.fabModel.archiveButton of
                Just ab ->
                    ( model, archiveItem model.csrftoken ab )

                Nothing ->
                    ( model, Cmd.none )

        ReceiveArchiveResp (Err _) ->
            ( model, Cmd.none )

        ReceiveArchiveResp (Ok _) ->
            case model.fabModel.archiveButton of
                Just ab ->
                    ( model, redirectToUrl ab.redirectUrl )

                Nothing ->
                    ( model, Cmd.none )

        ToggleFabView ->
            ( { model | fabModel = toggleFabView model.fabModel }, Cmd.none )


toggleFabView : FabModel -> FabModel
toggleFabView model =
    case model.fabState of
        MenuHidden ->
            { model | fabState = MenuVisible }

        MenuVisible ->
            { model | fabState = MenuHidden }


archiveItem : CSRFToken -> ArchiveButton -> Cmd Msg
archiveItem csrftoken r =
    let
        body =
            encodeBody [ ( "archived", Encode.bool r.isArchived ) ]
    in
        post r.postUrl body csrftoken decodeAlwaysTrue
            |> Http.send (FabMsg << ReceiveArchiveResp)


port redirectToUrl : String -> Cmd msg
