module Update exposing (update)

import Form as F
import Messages exposing (..)
import Models exposing (Model, Settings, TwilioSettings)
import Navigation
import Notification as Notif
import PageVisibility
import Pages as P
import Pages.ApiSetup as ApiSetup
import Pages.Curator as C
import Pages.Debug as DG
import Pages.DeletePanel as DP
import Pages.ElvantoImport as EI
import Pages.FirstRun as FR
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.CreateAllGroup as CAG
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.SendAdhoc as SAF
import Pages.Forms.SendGroup as SGF
import Pages.Forms.SiteConfig as SCF
import Pages.Forms.UserProfile as UPF
import Pages.Fragments.ActionsPanel as ActionsPanel
import Pages.GroupComposer as GC
import Pages.GroupTable as GT
import Pages.InboundTable as IT
import Pages.KeyRespTable as KRT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.UserProfileTable as UPT
import Ports
import RemoteList as RL
import Route exposing (loc2Page, page2loc)
import Store.Model as Store
import Store.Optimistic
import Store.Request exposing (maybeFetchData)
import Store.Update as SU


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
        -- Store
        StoreMsg subMsg ->
            let
                ( newModel, storeCmds ) =
                    SU.update subMsg model
            in
            ( newModel, List.map (Cmd.map StoreMsg) storeCmds )

        -- Urls
        NewUrl str ->
            ( { model
                | notifications = Notif.empty
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
                    { model | dataStore = newDs, page = page }
            in
            ( newModel
            , List.concat
                [ List.map (Cmd.map StoreMsg) storeCmds
                , [ scrollTo "elmContainer", pageCmd ]
                ]
            )

        -- Global
        Nope ->
            ( model, [] )

        ScrollToId id ->
            ( model, [ scrollTo id ] )

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

        -- Fragments
        ActionsPanelMsg subMsg ->
            ActionsPanel.update subMsg model

        NotificationMsg subMsg ->
            ( { model | notifications = Notif.update subMsg model.notifications }, [] )

        DeletePanelMsg subMsg ->
            case model.page of
                P.DeletePanel dpModel ->
                    let
                        ( newdpModel, dpCmd ) =
                            DP.update
                                { csrftoken = model.settings.csrftoken }
                                subMsg
                                dpModel
                    in
                    ( { model | page = P.DeletePanel newdpModel }
                    , [ Cmd.map DeletePanelMsg dpCmd ]
                    )

                _ ->
                    ( model, [] )

        -- Pages
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
                P.ElvantoImport eiModel ->
                    let
                        ( newEIModel, notifications, cmds ) =
                            EI.update { topLevelMsg = ElvantoMsg, csrftoken = model.settings.csrftoken } subMsg eiModel
                    in
                    ( { model | page = P.ElvantoImport newEIModel }
                        |> Notif.updateNotifications notifications
                    , cmds
                    )

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
                        newData =
                            KRT.update
                                { csrftoken = model.settings.csrftoken
                                , isArchive = isArchive
                                , keyword = k
                                , store = model.dataStore
                                , optArchiveMatchingSms = Store.Optimistic.optArchiveMatchingSms
                                }
                                subMsg
                                keyRespModel
                    in
                    ( { model
                        | page = P.KeyRespTable newData.model newData.isArchive newData.keyword
                        , dataStore = newData.store
                      }
                    , List.map (Cmd.map KeyRespTableMsg) newData.cmds
                    )

                _ ->
                    ( model, [] )

        CuratorMsg subMsg ->
            case model.page of
                P.Curator cModel ->
                    ( { model | page = P.Curator (C.update subMsg cModel) }, [] )

                _ ->
                    ( model, [] )

        GroupTableMsg subMsg ->
            case model.page of
                P.GroupTable gtModel isArchive ->
                    ( { model | page = P.GroupTable (GT.update subMsg gtModel) isArchive }, [] )

                _ ->
                    ( model, [] )

        InboundTableMsg subMsg ->
            case model.page of
                P.InboundTable itModel ->
                    ( { model | page = P.InboundTable (IT.update subMsg itModel) }, [] )

                _ ->
                    ( model, [] )

        KeywordTableMsg subMsg ->
            case model.page of
                P.KeywordTable ktModel isArchive ->
                    ( { model | page = P.KeywordTable (KT.update subMsg ktModel) isArchive }, [] )

                _ ->
                    ( model, [] )

        OutboundTableMsg subMsg ->
            case model.page of
                P.OutboundTable otModel ->
                    ( { model | page = P.OutboundTable (OT.update subMsg otModel) }, [] )

                _ ->
                    ( model, [] )

        RecipientTableMsg subMsg ->
            case model.page of
                P.RecipientTable rtModel isArchive ->
                    ( { model | page = P.RecipientTable (RT.update subMsg rtModel) isArchive }, [] )

                _ ->
                    ( model, [] )

        ScheduledSmsTableMsg subMsg ->
            case model.page of
                P.ScheduledSmsTable sstModel ->
                    ( { model | page = P.ScheduledSmsTable (SST.update subMsg sstModel) }, [] )

                _ ->
                    ( model, [] )

        UserProfileTableMsg subMsg ->
            case model.page of
                P.UserProfileTable uptModel ->
                    ( { model | page = P.UserProfileTable (UPT.update subMsg uptModel) }, [] )

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

        UserProfileFormMsg subMsg ->
            case model.page of
                P.UserProfileForm upfModel pk ->
                    let
                        pageData =
                            UPF.update
                                { csrftoken = model.settings.csrftoken
                                , successPageUrl = page2loc <| P.UserProfileTable UPT.initialModel
                                , userprofiles = model.dataStore.userprofiles
                                , userPk = pk
                                }
                                subMsg
                                upfModel
                    in
                    formUpdate
                        (\um -> P.UserProfileForm um pk)
                        UserProfileFormMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        GroupFormMsg subMsg ->
            case model.page of
                P.GroupForm gfModel maybePk ->
                    let
                        pageData =
                            GF.update
                                { csrftoken = model.settings.csrftoken
                                , successPageUrl = page2loc <| P.GroupTable GT.initialModel False
                                , maybePk = maybePk
                                , groups = model.dataStore.groups
                                }
                                subMsg
                                gfModel
                    in
                    formUpdate
                        (\gm -> P.GroupForm gm maybePk)
                        GroupFormMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        ContactFormMsg subMsg ->
            case model.page of
                P.ContactForm cfModel maybePk ->
                    let
                        pageData =
                            CF.update
                                { csrftoken = model.settings.csrftoken
                                , successPageUrl = page2loc <| P.RecipientTable RT.initialModel False
                                , recipients = model.dataStore.recipients
                                , maybePk = maybePk
                                , canSeeContactNum = model.settings.userPerms.can_see_contact_nums
                                , canSeeContactNotes = model.settings.userPerms.can_see_contact_notes
                                }
                                subMsg
                                cfModel
                    in
                    formUpdate
                        (\cm -> P.ContactForm cm maybePk)
                        ContactFormMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        KeywordFormMsg subMsg ->
            case model.page of
                P.KeywordForm kfModel maybeK ->
                    let
                        pageData =
                            KF.update
                                { csrftoken = model.settings.csrftoken
                                , currentTime = model.currentTime
                                , keywords = model.dataStore.keywords
                                , maybeKeywordName = maybeK
                                , successPageUrl = page2loc <| P.KeywordTable KT.initialModel False
                                }
                                subMsg
                                kfModel
                    in
                    formUpdate
                        (\km -> P.KeywordForm km maybeK)
                        KeywordFormMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        SiteConfigFormMsg subMsg ->
            case model.page of
                P.SiteConfigForm scModel ->
                    let
                        pageData =
                            SCF.update
                                { csrftoken = model.settings.csrftoken
                                , successPageUrl = page2loc P.Home
                                }
                                subMsg
                                scModel

                        ( newModel, cmds ) =
                            formUpdate
                                P.SiteConfigForm
                                SiteConfigFormMsg
                                model
                                pageData
                    in
                    case subMsg of
                        SCF.ReceiveInitialData (Ok scData) ->
                            -- when we get new site config data from the server, we need to update our settings
                            ( { newModel | settings = updateSettings scData model.settings }, cmds )

                        _ ->
                            ( newModel, cmds )

                _ ->
                    ( model, [] )

        DefaultResponsesFormMsg subMsg ->
            case model.page of
                P.DefaultResponsesForm maybeDrfModel ->
                    let
                        pageData =
                            DRF.update
                                { csrftoken = model.settings.csrftoken
                                , successPageUrl = page2loc <| P.RecipientTable RT.initialModel False
                                }
                                subMsg
                                maybeDrfModel
                    in
                    formUpdate
                        P.DefaultResponsesForm
                        DefaultResponsesFormMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        SendAdhocMsg subMsg ->
            case model.page of
                P.SendAdhoc saModel ->
                    let
                        pageData =
                            SAF.update
                                { csrftoken = model.settings.csrftoken
                                , twilioCost =
                                    model.settings.twilio
                                        |> Maybe.map .sendingCost
                                        |> Maybe.withDefault 0.0
                                , outboundUrl = page2loc <| P.OutboundTable OT.initialModel
                                , scheduledUrl = page2loc <| P.ScheduledSmsTable SST.initialModel
                                , successPageUrl = page2loc <| P.OutboundTable OT.initialModel
                                , userPerms = model.settings.userPerms
                                }
                                subMsg
                                saModel
                    in
                    formUpdate
                        P.SendAdhoc
                        SendAdhocMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        SendGroupMsg subMsg ->
            case model.page of
                P.SendGroup sgModel ->
                    let
                        pageData =
                            SGF.update
                                { csrftoken = model.settings.csrftoken
                                , groups = RL.toList model.dataStore.groups
                                , outboundUrl = page2loc <| P.OutboundTable OT.initialModel
                                , scheduledUrl = page2loc <| P.ScheduledSmsTable SST.initialModel
                                , successPageUrl = page2loc <| P.OutboundTable OT.initialModel
                                , userPerms = model.settings.userPerms
                                }
                                subMsg
                                sgModel
                    in
                    formUpdate
                        P.SendGroup
                        SendGroupMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        CreateAllGroupMsg subMsg ->
            case model.page of
                P.CreateAllGroup cagModel ->
                    let
                        pageData =
                            CAG.update
                                { csrftoken = model.settings.csrftoken
                                , successPageUrl = page2loc <| P.GroupTable GT.initialModel False
                                }
                                subMsg
                                cagModel
                    in
                    formUpdate
                        P.CreateAllGroup
                        CreateAllGroupMsg
                        model
                        pageData

                _ ->
                    ( model, [] )

        ContactImportMsg subMsg ->
            case model.page of
                P.ContactImport ciModel ->
                    let
                        pageData =
                            CI.update
                                { csrftoken = model.settings.csrftoken
                                , successPageUrl = page2loc P.Home
                                }
                                subMsg
                                ciModel
                    in
                    formUpdate
                        P.ContactImport
                        ContactImportMsg
                        model
                        pageData

                _ ->
                    ( model, [] )


formUpdate : (pageModel -> P.Page) -> (pageMsg -> Msg) -> Model -> F.UpdateResp pageMsg pageModel -> ( Model, List (Cmd Msg) )
formUpdate toPage toMsg model { pageModel, cmd, notifications, maybeNewUrl } =
    ( { model | page = toPage pageModel }
        |> Notif.updateNotifications notifications
    , case maybeNewUrl of
        Nothing ->
            [ Cmd.map toMsg cmd ]

        Just newUrl ->
            [ Navigation.newUrl newUrl ]
    )


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


updateSettings : SCF.FModel -> Settings -> Settings
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


scrollTo : String -> Cmd Msg
scrollTo id =
    Ports.scrollIntoView id
