module Update exposing (update)

import Http
import Json.Decode as Decode
import Messages exposing (..)
import Models exposing (..)
import Navigation
import Ports exposing (saveDataStore)
import Regex
import Remote exposing (increasePageSize, fetchData, maybeFetchData)
import Route exposing (loc2Page)
import Update.DataStore exposing (updateNewData)
import Update.ElvantoImport
import Update.Fab
import Update.FirstRun
import Update.GroupComposer
import Update.GroupMemberSelect
import Update.GroupTable
import Update.InboundTable
import Update.KeyRespTable
import Update.KeywordTable
import Update.Notification as Notif
import Update.RecipientTable
import Update.ScheduledSmsTable
import Update.SendAdhoc
import Update.SendGroup
import Update.UserProfileTable
import Update.Wall
import View.FilteringTable as FT


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( newModel, cmds ) =
            updateHelper msg model

        newCmds =
            case msg of
                LoadDataStore _ ->
                    cmds

                _ ->
                    case newModel.dataStore == model.dataStore of
                        True ->
                            cmds

                        False ->
                            (saveDataStore <| encodeDataStore newModel.dataStore)
                                :: cmds
    in
        ( newModel, Cmd.batch newCmds )


updateHelper : Msg -> Model -> ( Model, List (Cmd Msg) )
updateHelper msg model =
    case msg of
        Nope ->
            ( model, [] )

        NewUrl str ->
            ( { model | fabModel = MenuHidden }
            , [ Navigation.newUrl str ]
            )

        UrlChange location ->
            let
                page =
                    loc2Page location model.settings
            in
                ( { model
                    | page = page
                    , loadingStatus = NoRequestSent
                    , filterRegex = Regex.regex ""
                    , sendAdhoc = Update.SendAdhoc.resetForm page
                    , sendGroup = Update.SendGroup.resetForm page
                  }
                , [ maybeFetchData page ]
                )

        -- Load data
        LoadData ->
            ( { model | loadingStatus = waitingHelper model.loadingStatus }, [ maybeFetchData model.page ] )

        ReceiveRawResp dt (Ok resp) ->
            let
                newModel =
                    model
                        |> updateNewData dt resp
                        |> updateLoadingStatus resp.next

                cmds =
                    case resp.next of
                        Nothing ->
                            []

                        Just url ->
                            [ fetchData ( dt, increasePageSize url ) ]
            in
                ( newModel, cmds )

        ReceiveRawResp _ (Err e) ->
            handleLoadingFailed e model

        LoadDataStore str ->
            let
                ds =
                    Decode.decodeString (Decode.at [ "data" ] decodeDataStore) str
                        |> Result.withDefault model.dataStore
            in
                ( { model | dataStore = ds }, [] )

        FabMsg subMsg ->
            Update.Fab.update subMsg model

        NotificationMsg subMsg ->
            Notif.update subMsg model

        FirstRunMsg subMsg ->
            Update.FirstRun.update subMsg model

        ElvantoMsg subMsg ->
            Update.ElvantoImport.update subMsg model

        InboundTableMsg subMsg ->
            Update.InboundTable.update subMsg model

        RecipientTableMsg subMsg ->
            Update.RecipientTable.update subMsg model

        KeywordTableMsg subMsg ->
            Update.KeywordTable.update subMsg model

        GroupTableMsg subMsg ->
            Update.GroupTable.update subMsg model

        GroupComposerMsg subMsg ->
            ( Update.GroupComposer.update subMsg model, [] )

        GroupMemberSelectMsg subMsg ->
            Update.GroupMemberSelect.update subMsg model

        WallMsg subMsg ->
            Update.Wall.update subMsg model

        UserProfileTableMsg subMsg ->
            Update.UserProfileTable.update subMsg model

        ScheduledSmsTableMsg subMsg ->
            Update.ScheduledSmsTable.update subMsg model

        KeyRespTableMsg subMsg ->
            Update.KeyRespTable.update subMsg model

        SendAdhocMsg subMsg ->
            Update.SendAdhoc.update subMsg model

        SendGroupMsg subMsg ->
            Update.SendGroup.update subMsg model

        -- Filtering Table
        UpdateTableFilter filterText ->
            ( { model | filterRegex = FT.textToRegex filterText }, [] )

        CurrentTime t ->
            ( { model | currentTime = t }, [] )


updateLoadingStatus : Maybe String -> Model -> Model
updateLoadingStatus next model =
    let
        loadingStatus =
            case next of
                Nothing ->
                    FinalPageReceived

                _ ->
                    waitingHelper model.loadingStatus
    in
        { model | loadingStatus = loadingStatus }


waitingHelper : LoadingStatus -> LoadingStatus
waitingHelper ls =
    case ls of
        WaitingOnRefresh ->
            WaitingOnRefresh

        _ ->
            WaitingForPage


userFacingErrorMessage : Http.Error -> String
userFacingErrorMessage err =
    case err of
        Http.BadUrl _ ->
            "That's a bad URL. Sorry."

        Http.NetworkError ->
            "Looks like there may be something wrong with your internet connection :("

        Http.BadStatus _ ->
            "Something went wrong there. Sorry."

        Http.BadPayload _ _ ->
            "Something went wrong there. Sorry."

        Http.Timeout ->
            "It took too long to reach the server..."


handleLoadingFailed : Http.Error -> Model -> ( Model, List (Cmd Msg) )
handleLoadingFailed err model =
    let
        niceMsg =
            userFacingErrorMessage err

        ( newModel, cmd ) =
            { model | loadingStatus = RespFailed <| niceMsg }
                |> Notif.createLoadingFailed niceMsg
    in
        ( newModel, [ cmd ] )
