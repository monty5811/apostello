module Update exposing (update)

import Dict
import FilteringTable as FT
import Forms.DatePickers exposing (initDateTimePickers)
import Forms.Update as F
import Messages exposing (..)
import Models exposing (FabModel(..), Model, Settings)
import Navigation
import Pages.ApiSetup.Update as ApiSetup
import Pages.ElvantoImport.Update as ElvImp
import Pages.FirstRun.Update as FR
import Pages.Forms.DefaultResponses.Remote as DRFR
import Pages.Forms.SiteConfig.Remote as SCFR
import Pages.Fragments.Fab.Update as Fab
import Pages.Fragments.Notification.Update as Notif
import Pages.GroupComposer.Update as GC
import Pages.KeyRespTable.Update as KRT
import Ports exposing (saveDataStore)
import Route exposing (loc2Page)
import Store.Encode exposing (encodeDataStore)
import Store.Messages exposing (StoreMsg(LoadDataStore))
import Store.Model as Store
import Store.Request exposing (maybeFetchData)
import Store.Update as SU


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
            ( { model
                | fabModel = MenuHidden
                , notifications = Dict.empty
              }
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
                , table = FT.initialModel
              }
            , []
            )
                |> initDateTimePickers
                |> maybeFetchData
                |> SCFR.maybeFetchConfig
                |> DRFR.maybeFetchResps

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

        GroupComposerMsg subMsg ->
            ( GC.update subMsg model, [] )

        KeyRespTableMsg subMsg ->
            KRT.update subMsg model

        ApiSetupMsg subMsg ->
            ApiSetup.update subMsg model

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
            (saveDataStore <| encodeDataStore newModel.dataStore)
                :: cmds
