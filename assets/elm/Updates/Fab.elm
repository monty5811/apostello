module Updates.Fab exposing (update)

import Decoders exposing (decodeAlwaysTrue)
import DjangoSend exposing (archivePost)
import Http
import Messages exposing (..)
import Models exposing (..)
import Navigation


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
                    ( model, Navigation.load ab.redirectUrl )

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
    archivePost csrftoken r.postUrl r.isArchived decodeAlwaysTrue
        |> Http.send (FabMsg << ReceiveArchiveResp)
