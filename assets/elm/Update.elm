module Update exposing (update)

import Decoders exposing (..)
import Helpers exposing (handleLoadingFailed, increasePageSize)
import Messages exposing (..)
import Models exposing (..)
import Remote exposing (..)
import Updates.ElvantoImport
import Updates.Fab
import Updates.FirstRun
import Updates.GroupComposer
import Updates.GroupMemberSelect
import Updates.GroupTable
import Updates.InboundTable
import Updates.KeyRespTable
import Updates.KeywordTable
import Updates.Notification
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
            case model.page of
                Fab ->
                    ( model, Cmd.none )

                _ ->
                    ( { model | loadingStatus = loadingType }, fetchData model.dataUrl )

        ReceiveRawResp (Ok resp) ->
            ( model
                |> updateNewData resp
                |> updateLoadingStatus resp.next
            , case resp.next of
                Nothing ->
                    Cmd.none

                Just url ->
                    fetchData (increasePageSize url)
            )

        ReceiveRawResp (Err e) ->
            handleLoadingFailed model

        FabMsg subMsg ->
            Updates.Fab.update subMsg model

        NotificationMsg subMsg ->
            Updates.Notification.update subMsg model

        FirstRunMsg subMsg ->
            Updates.FirstRun.update subMsg model

        ElvantoMsg subMsg ->
            Updates.ElvantoImport.update subMsg model

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
            ( { model | currentTime = t }, Cmd.none )


updateLoadingStatus : Maybe String -> Model -> Model
updateLoadingStatus next model =
    let
        loadingStatus =
            case next of
                Nothing ->
                    Finished

                _ ->
                    WaitingForSubsequent
    in
        { model | loadingStatus = loadingStatus }


updateNewData : RawResponse -> Model -> Model
updateNewData rawResp model =
    case model.page of
        OutboundTable ->
            { model | outboundTable = Updates.OutboundTable.updateModel model.outboundTable (dataFromResp smsoutboundDecoder rawResp) }

        InboundTable ->
            { model | inboundTable = Updates.InboundTable.updateSms model.inboundTable (dataFromResp smsinboundDecoder rawResp) }

        GroupTable ->
            { model | groupTable = Updates.GroupTable.updateGroups model.groupTable (dataFromResp recipientgroupDecoder rawResp) }

        GroupComposer ->
            { model | groupComposer = Updates.GroupComposer.updateGroups model.groupComposer (dataFromResp recipientgroupDecoder rawResp) }

        GroupSelect ->
            { model | groupSelect = Updates.GroupMemberSelect.updateGroup model.groupSelect (itemFromResp nullGroup recipientgroupDecoder rawResp) }

        RecipientTable ->
            { model | recipientTable = Updates.RecipientTable.updateRecipients model.recipientTable (dataFromResp recipientDecoder rawResp) }

        KeywordTable ->
            { model | keywordTable = Updates.KeywordTable.updateKeywords model.keywordTable (dataFromResp keywordDecoder rawResp) }

        ElvantoImport ->
            { model | elvantoImport = Updates.ElvantoImport.updateGroups model.elvantoImport (dataFromResp elvantogroupDecoder rawResp) }

        Wall ->
            { model | wall = Updates.Wall.updateSms model.wall (dataFromResp smsinboundsimpleDecoder rawResp) }

        Curator ->
            { model | wall = Updates.Wall.updateSms model.wall (dataFromResp smsinboundsimpleDecoder rawResp) }

        UserProfileTable ->
            { model | userProfileTable = Updates.UserProfileTable.updateUserProfiles model.userProfileTable (dataFromResp userprofileDecoder rawResp) }

        ScheduledSmsTable ->
            { model | scheduledSmsTable = Updates.ScheduledSmsTable.updateSms model.scheduledSmsTable (dataFromResp queuedsmsDecoder rawResp) }

        KeyRespTable ->
            { model | keyRespTable = Updates.KeyRespTable.updateSms model.keyRespTable (dataFromResp smsinboundDecoder rawResp) }

        Fab ->
            model

        FirstRun ->
            model
