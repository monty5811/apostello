module Update exposing (update)

import FilteringTable as FT
import Forms.Update as F
import Messages exposing (..)
import Models exposing (MenuModel(MenuHidden, MenuVisible), Model, Settings, TwilioSettings)
import Navigation
import Notification as Notif
import PageVisibility
import Pages as P
import Pages.ApiSetup as ApiSetup
import Pages.Debug as DG
import Pages.ElvantoImport as ElvImp
import Pages.FirstRun as FR
import Pages.Forms.SiteConfig as SCF
import Pages.Fragments.SidePanel as SidePanel
import Pages.GroupComposer as GC
import Pages.KeyRespTable as KRT
import Route exposing (loc2Page)
import Store.Model as Store
import Store.Optimistic
import Store.Request exposing (maybeFetchData)
import Store.Update as SU
import WebPush


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( newModel, cmds ) =
            updateHelper msg model
    in
    ( newModel
        |> maybeAddEmailWarning
        |> maybeAddTwilioWarning
    , Cmd.batch cmds
    )


updateHelper : Msg -> Model -> ( Model, List (Cmd Msg) )
updateHelper msg model =
    case msg of
        Nope ->
            ( model, [] )

        FormMsg ((SiteConfigFormMsg (SCF.ReceiveInitialData (Ok scData))) as formMsg) ->
            -- when we get new site config data from the server, we need to update our settings
            -- and then we call the `F.update` function as normal:
            { model | settings = updateSettings scData model.settings }
                |> F.update formMsg

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
                ( page, pageCmd ) =
                    loc2Page location model.settings

                ( newDs, storeCmds ) =
                    maybeFetchData page <| Store.resetStatus model.dataStore

                newModel =
                    { model | dataStore = newDs, page = page, table = FT.initialModel }
            in
            ( newModel
            , List.concat
                [ List.map (Cmd.map StoreMsg) storeCmds
                , [ pageCmd ]
                ]
            )

        -- Load data
        StoreMsg subMsg ->
            let
                ( newModel, storeCmds ) =
                    SU.update subMsg model
            in
            ( newModel, List.map (Cmd.map StoreMsg) storeCmds )

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
                    ( { model | page = P.FirstRun newFrModel }
                    , List.map (Cmd.map FirstRunMsg) frCmds
                    )

                _ ->
                    ( model, [] )

        DebugMsg subMsg ->
            case model.page of
                P.Debug dgModel ->
                    let
                        ( newDgModel, dgCmds ) =
                            DG.update model.settings.csrftoken subMsg dgModel
                    in
                    ( { model | page = P.Debug newDgModel }
                    , List.map (Cmd.map DebugMsg) dgCmds
                    )

                _ ->
                    ( model, [] )

        ElvantoMsg subMsg ->
            case model.page of
                P.ElvantoImport ->
                    ElvImp.update { topLevelMsg = ElvantoMsg, csrftoken = model.settings.csrftoken } subMsg model

                _ ->
                    ( model, [] )

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
                    ( { model
                        | page = P.KeyRespTable newKRModel newIsArchive newK
                        , dataStore = newStore
                      }
                    , List.map (Cmd.map KeyRespTableMsg) krtCmds
                    )

                _ ->
                    ( model, [] )

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
                    ( { model | page = P.ApiSetup newKey, notifications = notifications }
                    , List.map (Cmd.map ApiSetupMsg) apiCmds
                    )

                _ ->
                    ( model, [] )

        -- Filtering Table
        TableMsg subMsg ->
            ( { model | table = FT.update subMsg model.table }, [] )

        CurrentTime t ->
            ( { model | currentTime = t }, [] )

        VisibilityChange state ->
            case state of
                PageVisibility.Hidden ->
                    ( { model | pageVisibility = state }, [] )

                PageVisibility.Visible ->
                    -- fetch data when page becomes visible again
                    let
                        ( newDataStore, storeCmds ) =
                            maybeFetchData model.page model.dataStore
                    in
                    ( { model
                        | dataStore = newDataStore
                        , pageVisibility = state
                      }
                    , List.map (Cmd.map StoreMsg) storeCmds
                    )

        KeyPressed keyCode ->
            case ( model.menuState, keyCode ) of
                ( MenuVisible, 27 ) ->
                    ( { model | menuState = MenuHidden }, [] )

                ( _, _ ) ->
                    ( model, [] )

        WebPushMsg subMsg ->
            let
                ( wpModel, wpCmd ) =
                    WebPush.update model.settings.csrftoken subMsg model.webPush
            in
            ( { model | webPush = wpModel }, [ Cmd.map WebPushMsg wpCmd ] )


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


updateSettings : SCF.Model -> Settings -> Settings
updateSettings newSCModel settings =
    let
        newTwilio =
            Maybe.map2
                TwilioSettings
                newSCModel.twilio_sending_cost
                newSCModel.twilio_from_num

        newEmailSetup =
            [ isJust newSCModel.email_from
            , isJust newSCModel.email_host
            , isJust newSCModel.email_password
            , isJust newSCModel.email_port
            , isJust newSCModel.email_username
            ]
                |> List.all identity
    in
    { settings
        | smsCharLimit = newSCModel.sms_char_limit
        , defaultNumberPrefix = newSCModel.default_number_prefix
        , twilio = newTwilio
        , isEmailSetup = newEmailSetup
    }


isJust : Maybe a -> Bool
isJust m =
    m /= Nothing
