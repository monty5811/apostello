module Update exposing (update)

import Encoders exposing (encodeDataStore)
import Http
import Json.Decode as Decode
import Messages exposing (..)
import Models exposing (..)
import Navigation
import Ports exposing (saveDataStore)
import Regex
import Remote exposing (increasePageSize, fetchData, maybeFetchData)
import Route exposing (loc2Page)
import Updates.DataStore exposing (updateNewData)
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
import Updates.RecipientTable
import Updates.ScheduledSmsTable
import Updates.SendAdhoc
import Updates.SendGroup
import Updates.UserProfileTable
import Updates.Wall
import Views.FilteringTable as FT


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
                    , sendAdhoc = Updates.SendAdhoc.resetForm page
                    , sendGroup = Updates.SendGroup.resetForm page
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

        ReceiveRawResp dt (Err e) ->
            handleLoadingFailed e model

        LoadDataStore str ->
            let
                ds =
                    Decode.decodeString (Decode.at [ "data" ] dataStoreDecoder) str
                        |> Result.withDefault model.dataStore
            in
                ( { model | dataStore = ds }, [] )

        FabMsg subMsg ->
            Updates.Fab.update subMsg model

        NotificationMsg subMsg ->
            ( Updates.Notification.update subMsg model, [] )

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
            ( Updates.GroupComposer.update subMsg model, [] )

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

        SendAdhocMsg subMsg ->
            Updates.SendAdhoc.update subMsg model

        SendGroupMsg subMsg ->
            Updates.SendGroup.update subMsg model

        -- Filtering Table
        UpdateTableFilter filterText ->
            ( { model | filterRegex = (FT.textToRegex filterText) }, [] )

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


handleLoadingFailed : Http.Error -> Model -> ( Model, List (Cmd Msg) )
handleLoadingFailed err model =
    let
        errStr =
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
    in
        ( { model | loadingStatus = RespFailed errStr } |> Updates.Notification.createLoadingFailedNotification, [] )
