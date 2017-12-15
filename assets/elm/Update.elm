module Update exposing (update)

import FilteringTable as FT
import Forms.Update as F
import Http
import Messages exposing (..)
import Models exposing (MenuModel(MenuHidden, MenuVisible), Model, Settings)
import Navigation
import Notification as Notif
import PageVisibility
import Pages as P
import Pages.ApiSetup as ApiSetup
import Pages.Debug as DG
import Pages.ElvantoImport as ElvImp
import Pages.FirstRun as FR
import Pages.Forms.DefaultResponses as DRF
import Pages.Fragments.SidePanel as SidePanel
import Pages.GroupComposer as GC
import Pages.KeyRespTable as KRT
import Ports exposing (saveDataStore)
import Rocket exposing ((=>))
import Route exposing (loc2Page)
import Store.Encode exposing (encodeDataStore)
import Store.Messages exposing (StoreMsg(LoadDataStore))
import Store.Model as Store
import Store.Optimistic
import Store.Request exposing (maybeFetchData)
import Store.Update as SU
import Urls
import WebPush


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( newModel, cmds ) =
            updateHelper msg model

        newCmds =
            maybeSaveDataStore msg model newModel cmds
    in
    ( newModel
        |> maybeAddEmailWarning
        |> maybeAddTwilioWarning
    , Cmd.batch newCmds
    )


updateHelper : Msg -> Model -> ( Model, List (Cmd Msg) )
updateHelper msg model =
    case msg of
        Nope ->
            ( model, [] )

        ToggleMenu ->
            case model.menuState of
                MenuHidden ->
                    ( { model | menuState = MenuVisible }, [] )

                MenuVisible ->
                    ( { model | menuState = MenuHidden }, [] )

        NewUrl str ->
            ( { model
                | notifications = Notif.empty
                , menuState = MenuHidden
              }
            , [ Navigation.newUrl str ]
            )

        UrlChange location ->
            let
                page =
                    loc2Page location model.settings

                ( newDs, storeCmds ) =
                    maybeFetchData page <| Store.resetStatus model.dataStore

                newModel =
                    { model | dataStore = newDs, page = page, table = FT.initialModel }

                datePickerCmds =
                    F.initDateTimePickers model.page
            in
            ( newModel
            , List.concat
                [ List.map (Cmd.map StoreMsg) storeCmds
                , List.map (Cmd.map FormMsg) datePickerCmds
                ]
            )
                |> F.maybeFetchConfig
                |> maybeFetchResps

        -- Load data
        StoreMsg subMsg ->
            let
                ( newModel, storeCmds ) =
                    SU.update subMsg model
            in
            newModel => List.map (Cmd.map StoreMsg) storeCmds

        FormMsg subMsg ->
            F.update subMsg model

        SidePanelMsg subMsg ->
            SidePanel.update subMsg model

        NotificationMsg subMsg ->
            ( { model | notifications = Notif.update subMsg model.notifications }, [] )

        FirstRunMsg subMsg ->
            case model.page of
                P.FirstRun frModel ->
                    let
                        ( newFrModel, frCmds ) =
                            FR.update model.settings.csrftoken subMsg frModel
                    in
                    { model | page = P.FirstRun newFrModel }
                        => List.map (Cmd.map FirstRunMsg) frCmds

                _ ->
                    model => []

        DebugMsg subMsg ->
            case model.page of
                P.Debug dgModel ->
                    let
                        ( newDgModel, dgCmds ) =
                            DG.update model.settings.csrftoken subMsg dgModel
                    in
                    { model | page = P.Debug newDgModel }
                        => List.map (Cmd.map DebugMsg) dgCmds

                _ ->
                    model => []

        ElvantoMsg subMsg ->
            case model.page of
                P.ElvantoImport ->
                    ElvImp.update { topLevelMsg = ElvantoMsg, csrftoken = model.settings.csrftoken } subMsg model

                _ ->
                    model => []

        GroupComposerMsg subMsg ->
            case model.page of
                P.GroupComposer _ ->
                    ( { model | page = P.GroupComposer <| GC.update subMsg }, [] )

                _ ->
                    ( model, [] )

        KeyRespTableMsg subMsg ->
            case model.page of
                P.KeyRespTable keyRespModel isArchive k ->
                    let
                        ( newKRModel, newIsArchive, newK, newStore, krtCmds ) =
                            KRT.update subMsg
                                { csrftoken = model.settings.csrftoken
                                , keyRespModel = keyRespModel
                                , isArchive = isArchive
                                , keyword = k
                                , store = model.dataStore
                                , optArchiveMatchingSms = Store.Optimistic.optArchiveMatchingSms
                                }
                    in
                    { model
                        | page = P.KeyRespTable newKRModel newIsArchive newK
                        , dataStore = newStore
                    }
                        => List.map (Cmd.map KeyRespTableMsg) krtCmds

                _ ->
                    model => []

        ApiSetupMsg subMsg ->
            case model.page of
                P.ApiSetup maybeKey ->
                    let
                        ( newKey, notifications, apiCmds ) =
                            ApiSetup.update subMsg
                                { key = maybeKey
                                , notifications = model.notifications
                                , csrftoken = model.settings.csrftoken
                                }
                    in
                    { model | page = P.ApiSetup newKey, notifications = notifications }
                        => List.map (Cmd.map ApiSetupMsg) apiCmds

                _ ->
                    model => []

        -- Filtering Table
        TableMsg subMsg ->
            ( { model | table = FT.update subMsg model.table }, [] )

        CurrentTime t ->
            ( { model | currentTime = t }, [] )

        VisibilityChange state ->
            case state of
                PageVisibility.Hidden ->
                    { model | pageVisibility = state } => []

                PageVisibility.Visible ->
                    -- fetch data when page becomes visible again
                    let
                        ( newDataStore, storeCmds ) =
                            maybeFetchData model.page model.dataStore
                    in
                    { model
                        | dataStore = newDataStore
                        , pageVisibility = state
                    }
                        => List.map (Cmd.map StoreMsg) storeCmds

        KeyPressed keyCode ->
            case ( model.menuState, keyCode ) of
                ( MenuVisible, 27 ) ->
                    { model | menuState = MenuHidden } => []

                ( _, _ ) ->
                    model => []

        WebPushMsg subMsg ->
            let
                ( wpModel, wpCmd ) =
                    WebPush.update model.settings.csrftoken subMsg model.webPush
            in
            ( { model | webPush = wpModel }, [ Cmd.map WebPushMsg wpCmd ] )


maybeSaveDataStore : Msg -> Model -> Model -> List (Cmd Msg) -> List (Cmd Msg)
maybeSaveDataStore msg oldModel newModel cmds =
    case msg of
        StoreMsg subMsg ->
            case subMsg of
                LoadDataStore _ ->
                    cmds

                _ ->
                    addSaveDataStoreCmd oldModel newModel cmds

        _ ->
            addSaveDataStoreCmd oldModel newModel cmds


addSaveDataStoreCmd : Model -> Model -> List (Cmd Msg) -> List (Cmd Msg)
addSaveDataStoreCmd oldModel newModel cmds =
    case newModel.dataStore == oldModel.dataStore of
        True ->
            cmds

        False ->
            (saveDataStore <| encodeDataStore newModel.dataStore)
                :: cmds


maybeFetchResps : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
maybeFetchResps ( model, cmds ) =
    let
        req =
            Http.get Urls.api_default_responses DRF.decodeModel
    in
    case model.page of
        P.DefaultResponsesForm _ ->
            ( model, cmds ++ [ Http.send (FormMsg << DefaultResponsesFormMsg << DRF.ReceiveInitialModel) req ] )

        _ ->
            ( model, cmds )


maybeAddTwilioWarning : Model -> Model
maybeAddTwilioWarning model =
    let
        notif =
            Notif.Notification
                Notif.ErrorNotification
                "You need to setup your Twilio credentials.\n\nYou won't be able to send messages until you do."
                False
    in
    case model.settings.twilio of
        Nothing ->
            if List.member notif model.notifications then
                model
            else
                { model | notifications = notif :: model.notifications }

        Just _ ->
            { model | notifications = Notif.remove notif model.notifications }


maybeAddEmailWarning : Model -> Model
maybeAddEmailWarning model =
    let
        notif =
            Notif.Notification
                Notif.WarningNotification
                "You need to setup your email credentials.\n\napostello won't be able to send emails until you do. This means new users cannot confirm their email address and no notifications can be sent"
                False
    in
    case model.settings.isEmailSetup of
        False ->
            if List.member notif model.notifications then
                model
            else
                { model | notifications = notif :: model.notifications }

        True ->
            { model | notifications = Notif.remove notif model.notifications }
