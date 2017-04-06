module Update.Fab exposing (update)

import DjangoSend exposing (archivePost)
import Helpers exposing (decodeAlwaysTrue)
import Http
import Messages
    exposing
        ( Msg(FabMsg)
        , FabMsg
            ( ReceiveArchiveResp
            , ArchiveItem
            , ToggleFabView
            )
        )
import Models exposing (Model, FabModel(..), CSRFToken)
import Navigation


update : FabMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ArchiveItem redirectUrl url isArchived ->
            ( model, [ archiveItem model.settings.csrftoken redirectUrl url isArchived ] )

        ReceiveArchiveResp _ (Err _) ->
            ( model, [] )

        ReceiveArchiveResp url (Ok _) ->
            ( model, [ Navigation.load url ] )

        ToggleFabView ->
            ( { model | fabModel = toggleFabView model.fabModel }, [] )


toggleFabView : FabModel -> FabModel
toggleFabView model =
    case model of
        MenuHidden ->
            MenuVisible

        MenuVisible ->
            MenuHidden


archiveItem : CSRFToken -> String -> String -> Bool -> Cmd Msg
archiveItem csrftoken redirectUrl url isArchived =
    archivePost csrftoken url isArchived decodeAlwaysTrue
        |> Http.send (FabMsg << ReceiveArchiveResp redirectUrl)
