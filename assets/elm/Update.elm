module Update exposing (update)

import Actions exposing (fetchData)
import Messages exposing (..)
import Models exposing (..)
import Updates.ElvantoImport
import Updates.Fab
import Updates.FirstRun
import Updates.GroupComposer
import Updates.GroupMemberSelect
import Updates.GroupTable
import Updates.InboundTable
import Updates.KeyRespTable
import Updates.KeywordTable
import Updates.OutboundTable
import Updates.RecipientTable
import Updates.ScheduledSmsTable
import Updates.UserProfileTable
import Updates.Wall
import Views.FilteringTable as FT


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Load data
        LoadData loadingType ->
            ( { model | loadingStatus = loadingType }, fetchData model.page model.dataUrl )

        FabMsg subMsg ->
            Updates.Fab.update subMsg model

        FirstRunMsg subMsg ->
            Updates.FirstRun.update subMsg model

        ElvantoMsg subMsg ->
            Updates.ElvantoImport.update subMsg model

        OutboundTableMsg subMsg ->
            Updates.OutboundTable.update subMsg model

        InboundTableMsg subMsg ->
            Updates.InboundTable.update subMsg model

        RecipientTableMsg subMsg ->
            Updates.RecipientTable.update subMsg model

        KeywordTableMsg subMsg ->
            Updates.KeywordTable.update subMsg model

        GroupTableMsg subMsg ->
            Updates.GroupTable.update subMsg model

        GroupComposerMsg subMsg ->
            Updates.GroupComposer.update subMsg model

        GroupMemberSelectMsg subMsg ->
            Updates.GroupMemberSelect.update subMsg model

        WallMsg subMsg ->
            Updates.Wall.update subMsg model

        UserProfileTableMsg subMsg ->
            Updates.UserProfileTable.update subMsg model

        ScheduledSmsTableMsg subMsg ->
            Updates.ScheduledSmsTable.update subMsg model

        KeyRespTableMsg subMsg ->
            Updates.KeyRespTable.update subMsg model

        -- Filtering Table
        UpdateTableFilter filterText ->
            ( { model | filterRegex = (FT.textToRegex filterText) }, Cmd.none )

        CurrentTime t ->
            ( { model | currentTime = Just t }, Cmd.none )
