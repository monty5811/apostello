module View exposing (view)

import Data.Store as Store
import Html exposing (Html, text)
import Messages exposing (Msg)
import Models exposing (Model)
import Pages exposing (FabOnlyPage(..), Page(..))
import Pages.AccessDenied as AD
import Pages.ContactForm.View as CF
import Pages.Curator as C
import Pages.ElvantoImport.View as EI
import Pages.Error404 as E404
import Pages.FirstRun.View as FR
import Pages.Fragments.Fab.View as F
import Pages.Fragments.Shell as Shell
import Pages.GroupComposer.View as GC
import Pages.GroupForm.View as GF
import Pages.GroupTable.View as GT
import Pages.Home as H
import Pages.InboundTable.View as IT
import Pages.KeyRespTable.View as KRT
import Pages.KeywordForm.View as KF
import Pages.KeywordTable.View as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable.View as RT
import Pages.ScheduledSmsTable.View as SST
import Pages.SendAdhocForm.View as SA
import Pages.SendGroupForm.View as SG
import Pages.SiteConfigForm.View as SCF
import Pages.UserProfileTable.View as UPT
import Pages.Wall.View as W


view : Model -> Html Msg
view model =
    let
        fab =
            F.view model.dataStore
                model.page
                model.fabModel
                (model.settings.userPerms.can_archive || model.settings.userPerms.user.is_staff)

        shell =
            Shell.view model

        mainContent =
            content model
    in
    shell mainContent fab


content : Model -> Html Msg
content model =
    case model.page of
        OutboundTable ->
            OT.view model.table model.dataStore.outboundSms

        InboundTable ->
            IT.view model.table model.dataStore.inboundSms

        GroupTable viewingArchive ->
            GT.view model.table (Store.filterArchived viewingArchive model.dataStore.groups)

        GroupComposer composerModel ->
            GC.view composerModel (Store.filterArchived False model.dataStore.groups)

        RecipientTable viewingArchive ->
            RT.view model.table <| Store.filterArchived viewingArchive model.dataStore.recipients

        KeywordTable viewingArchive ->
            KT.view model.table <| Store.filterArchived viewingArchive model.dataStore.keywords

        ElvantoImport ->
            EI.view model.table model.dataStore.elvantoGroups

        Wall ->
            W.view (model.dataStore.inboundSms |> Store.filterArchived False |> Store.filter (\s -> s.display_on_wall))

        Curator ->
            C.view model.table (model.dataStore.inboundSms |> Store.filterArchived False)

        UserProfileTable ->
            UPT.view model.table model.dataStore.userprofiles

        ScheduledSmsTable ->
            SST.view model.table model.currentTime model.dataStore.queuedSms

        KeyRespTable keyRespModel viewingArchive currentKeyword ->
            KRT.view viewingArchive
                model.table
                (model.dataStore.inboundSms |> Store.filterArchived viewingArchive |> Store.filter (filterByMatchedKeyword currentKeyword))
                keyRespModel
                currentKeyword

        FirstRun m ->
            FR.view m

        AccessDenied ->
            AD.view

        SendAdhoc saModel ->
            SA.view
                model.settings
                saModel
                (Store.filterArchived False model.dataStore.recipients)
                model.formStatus

        SendGroup sgModel ->
            SG.view
                model.settings
                sgModel
                (Store.filterArchived False model.dataStore.groups |> Store.filter (\x -> x.cost > 0))
                model.formStatus

        Error404 ->
            E404.view

        Home ->
            H.view

        GroupForm gfModel maybePk ->
            GF.view maybePk model.dataStore.groups gfModel model.formStatus

        ContactForm cfModel maybePk ->
            let
                incomingTable =
                    case maybePk of
                        Nothing ->
                            Nothing

                        Just pk ->
                            Just <| IT.view model.table (model.dataStore.inboundSms |> Store.filter (filterBySenderPk pk))
            in
            CF.view
                model.settings
                incomingTable
                maybePk
                model.dataStore.recipients
                cfModel
                model.formStatus

        KeywordForm kfModel maybeK ->
            KF.view
                model.dataStore
                maybeK
                kfModel
                model.formStatus

        SiteConfigForm scModel ->
            SCF.view
                model.dataStore
                scModel
                model.formStatus

        FabOnlyPage _ ->
            text ""



-- filter data for display


filterByMatchedKeyword : String -> { a | matched_keyword : String } -> Bool
filterByMatchedKeyword currentKeyword k =
    k.matched_keyword == currentKeyword


filterBySenderPk : Int -> { a | sender_pk : Maybe Int } -> Bool
filterBySenderPk pk recip =
    pk == Maybe.withDefault 0 recip.sender_pk
