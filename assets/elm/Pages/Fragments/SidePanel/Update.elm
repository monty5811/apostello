module Pages.Fragments.SidePanel.Update exposing (update)

import DjangoSend exposing (CSRFToken, archivePost)
import Helpers exposing (decodeAlwaysTrue)
import Http
import Messages
    exposing
        ( Msg(SidePanelMsg)
        , SidePanelMsg
            ( ArchiveItem
            , ReceiveArchiveResp
            )
        )
import Models exposing (Model)
import Navigation


update : SidePanelMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ArchiveItem redirectUrl url isArchived ->
            ( model, [ archiveItem model.settings.csrftoken redirectUrl url isArchived ] )

        ReceiveArchiveResp _ (Err _) ->
            ( model, [] )

        ReceiveArchiveResp url (Ok _) ->
            ( model, [ Navigation.load url ] )


archiveItem : CSRFToken -> String -> String -> Bool -> Cmd Msg
archiveItem csrf redirectUrl url isArchived =
    archivePost csrf url isArchived decodeAlwaysTrue
        |> Http.send (SidePanelMsg << ReceiveArchiveResp redirectUrl)
