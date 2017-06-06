module Update exposing (update)

import Data.Request exposing (StoreMsg(LoadDataStore))
import Data.Store as Store
import Data.Store.Update as SU
import Date
import DateTimePicker
import FilteringTable.Model as FTModel
import FilteringTable.Update as FT
import Forms.Update as F
import Messages exposing (..)
import Models exposing (FabModel(..), Model, Settings)
import Navigation
import Pages as P
import Pages.ContactForm.Update as CF
import Pages.ElvantoImport.Update as ElvImp
import Pages.FirstRun.Update as FR
import Pages.Fragments.Fab.Update as Fab
import Pages.Fragments.Notification.Update as Notif
import Pages.GroupComposer.Update as GC
import Pages.GroupForm.Update as GF
import Pages.GroupTable.Update as GT
import Pages.InboundTable.Update as IT
import Pages.KeyRespTable.Update as KRT
import Pages.KeywordForm.Messages as KFM
import Pages.KeywordForm.Update as KF
import Pages.KeywordTable.Update as KT
import Pages.RecipientTable.Update as RT
import Pages.ScheduledSmsTable.Update as SST
import Pages.SendAdhocForm.Messages as SAM
import Pages.SendAdhocForm.Update as SA
import Pages.SendGroupForm.Messages as SGM
import Pages.SendGroupForm.Update as SG
import Pages.SiteConfigForm.Model exposing (SiteConfigFormModel)
import Pages.SiteConfigForm.Remote as SCFR
import Pages.SiteConfigForm.Update as SCF
import Pages.UserProfileTable.Update as UPT
import Pages.Wall.Update as Wall
import Ports exposing (saveDataStore)
import Route exposing (loc2Page)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( newModel, cmds ) =
            updateHelper msg model

        newCmds =
            maybeSaveDataStore msg model newModel cmds
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
                , dataStore = Store.resetStatus model.dataStore
                , table = FTModel.initial
              }
            , []
            )
                |> initDateTimePickers
                |> SU.maybeFetchData
                |> SCFR.maybeFetchConfig

        ReceiveSiteConfigFormModel (Ok scModel) ->
            let
                newModel =
                    case model.page of
                        P.SiteConfigForm _ ->
                            { model | page = P.SiteConfigForm <| Just scModel }

                        _ ->
                            model
            in
            ( { newModel | settings = updateSettings scModel newModel.settings }, [] )

        ReceiveSiteConfigFormModel (Err _) ->
            ( model, [] )

        -- Load data
        StoreMsg subMsg ->
            SU.update subMsg model

        FormMsg subMsg ->
            F.update subMsg model

        FabMsg subMsg ->
            Fab.update subMsg model

        NotificationMsg subMsg ->
            Notif.update subMsg model

        FirstRunMsg subMsg ->
            FR.update subMsg model

        ElvantoMsg subMsg ->
            ElvImp.update subMsg model

        InboundTableMsg subMsg ->
            IT.update subMsg model

        RecipientTableMsg subMsg ->
            RT.update subMsg model

        KeywordTableMsg subMsg ->
            KT.update subMsg model

        GroupTableMsg subMsg ->
            GT.update subMsg model

        GroupComposerMsg subMsg ->
            ( GC.update subMsg model, [] )

        GroupFormMsg subMsg ->
            case model.page of
                P.GroupForm gfModel maybePk ->
                    ( { model | page = P.GroupForm (GF.update subMsg gfModel) maybePk }
                    , []
                    )

                _ ->
                    ( model, [] )

        ContactFormMsg subMsg ->
            case model.page of
                P.ContactForm cfModel maybePk ->
                    ( { model
                        | page =
                            P.ContactForm (CF.update subMsg cfModel)
                                maybePk
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        KeywordFormMsg subMsg ->
            case model.page of
                P.KeywordForm kfModel maybeK ->
                    ( { model
                        | page =
                            P.KeywordForm (KF.update subMsg kfModel)
                                maybeK
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        SiteConfigFormMsg subMsg ->
            case model.page of
                P.SiteConfigForm _ ->
                    ( { model
                        | page =
                            P.SiteConfigForm <| Just <| SCF.update subMsg
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        WallMsg subMsg ->
            Wall.update subMsg model

        UserProfileTableMsg subMsg ->
            UPT.update subMsg model

        ScheduledSmsTableMsg subMsg ->
            SST.update subMsg model

        KeyRespTableMsg subMsg ->
            KRT.update subMsg model

        SendAdhocMsg subMsg ->
            case model.page of
                P.SendAdhoc saModel ->
                    ( { model | page = P.SendAdhoc <| SA.update model.settings.twilioSendingCost subMsg saModel }, [] )

                _ ->
                    ( model, [] )

        SendGroupMsg subMsg ->
            case model.page of
                P.SendGroup sgModel ->
                    ( { model
                        | page =
                            P.SendGroup <|
                                SG.update
                                    (Store.toList model.dataStore.groups)
                                    subMsg
                                    sgModel
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        -- Filtering Table
        TableMsg subMsg ->
            ( { model | table = FT.update subMsg model.table }, [] )

        CurrentTime t ->
            ( { model | currentTime = t }, [] )


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
            (saveDataStore <| Store.encodeDataStore newModel.dataStore)
                :: cmds


initDateTimePickers : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
initDateTimePickers ( model, msgs ) =
    ( model, msgs ++ initDateTimePickersHelp model.page )


initDateTimePickersHelp : P.Page -> List (Cmd Msg)
initDateTimePickersHelp page =
    case page of
        P.KeywordForm model _ ->
            [ DateTimePicker.initialCmd initActTime model.datePickerActState
            , DateTimePicker.initialCmd initDeactTime model.datePickerDeactState
            ]

        P.SendAdhoc model ->
            [ DateTimePicker.initialCmd initSendAdhocDate model.datePickerState ]

        P.SendGroup model ->
            [ DateTimePicker.initialCmd initSendGroupDate model.datePickerState ]

        _ ->
            []


initActTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initActTime state maybeDate =
    KeywordFormMsg <| KFM.UpdateActivateTime state maybeDate


initDeactTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initDeactTime state maybeDate =
    KeywordFormMsg <| KFM.UpdateDeactivateTime state maybeDate


initSendAdhocDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendAdhocDate state maybeDate =
    SendAdhocMsg <| SAM.UpdateDate state maybeDate


initSendGroupDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendGroupDate state maybeDate =
    SendGroupMsg <| SGM.UpdateSGDate state maybeDate


updateSettings : SiteConfigFormModel -> Settings -> Settings
updateSettings newSCModel settings =
    { settings
        | smsCharLimit = newSCModel.sms_char_limit
        , defaultNumberPrefix = newSCModel.default_number_prefix
    }
