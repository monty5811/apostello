module View exposing (view)

import Html exposing (Html)
import Messages exposing (Msg)
import Models exposing (Model)
import Pages exposing (Page(..))
import Pages.AccessDenied as AD
import Pages.ApiSetup.View as ApiSetup
import Pages.Curator as C
import Pages.ElvantoImport.View as EI
import Pages.Error404 as E404
import Pages.FirstRun.View as FR
import Pages.Forms.Contact.View as CF
import Pages.Forms.ContactImport.View as CI
import Pages.Forms.CreateAllGroup.View as CAG
import Pages.Forms.DefaultResponses.View as DRF
import Pages.Forms.Group.View as GF
import Pages.Forms.Keyword.View as KF
import Pages.Forms.SendAdhoc.View as SA
import Pages.Forms.SendGroup.View as SG
import Pages.Forms.SiteConfig.View as SCF
import Pages.Forms.UserProfile.View as UPF
import Pages.Fragments.Fab.View as F
import Pages.Fragments.Shell as Shell
import Pages.GroupComposer.View as GC
import Pages.GroupTable as GT
import Pages.Help as Help
import Pages.Home as H
import Pages.InboundTable as IT
import Pages.KeyRespTable.View as KRT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.Usage as Usage
import Pages.UserProfileTable as UPT
import Pages.Wall as W
import RemoteList as RL
import Store.Model exposing (filterArchived)


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
            GT.view model.table (filterArchived viewingArchive model.dataStore.groups)

        GroupComposer composerModel ->
            GC.view composerModel (filterArchived False model.dataStore.groups)

        RecipientTable viewingArchive ->
            RT.view model.table <| filterArchived viewingArchive model.dataStore.recipients

        KeywordTable viewingArchive ->
            KT.view model.table <| filterArchived viewingArchive model.dataStore.keywords

        ElvantoImport ->
            EI.view model.table model.dataStore.elvantoGroups

        Wall ->
            W.view (model.dataStore.inboundSms |> filterArchived False |> RL.filter (\s -> s.display_on_wall))

        Curator ->
            C.view model.table (model.dataStore.inboundSms |> filterArchived False)

        UserProfileTable ->
            UPT.view model.table model.dataStore.userprofiles

        ScheduledSmsTable ->
            SST.view model.table model.currentTime model.dataStore.queuedSms

        KeyRespTable keyRespModel viewingArchive currentKeyword ->
            KRT.view viewingArchive
                model.table
                (model.dataStore.inboundSms |> filterArchived viewingArchive |> RL.filter (filterByMatchedKeyword currentKeyword))
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
                (filterArchived False model.dataStore.recipients)
                model.formStatus

        SendGroup sgModel ->
            SG.view
                model.settings
                sgModel
                (filterArchived False model.dataStore.groups |> RL.filter (\x -> x.cost > 0))
                model.formStatus

        Error404 ->
            E404.view

        Home ->
            H.view

        Help ->
            Help.view

        ContactImport ciModel ->
            CI.view
                model.settings.csrftoken
                model.formStatus
                ciModel

        GroupForm gfModel maybePk ->
            GF.view
                model.settings.csrftoken
                maybePk
                model.dataStore.groups
                gfModel
                model.formStatus

        ContactForm cfModel maybePk ->
            let
                incomingTable =
                    case maybePk of
                        Nothing ->
                            Nothing

                        Just pk ->
                            Just <|
                                IT.view model.table
                                    (model.dataStore.inboundSms
                                        |> RL.filter (filterBySenderPk pk)
                                    )
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
                model.settings.csrftoken
                model.currentTime
                model.dataStore
                maybeK
                kfModel
                model.formStatus

        SiteConfigForm scModel ->
            SCF.view
                model.settings.csrftoken
                model.dataStore
                scModel
                model.formStatus

        DefaultResponsesForm drModel ->
            DRF.view
                model.settings.csrftoken
                drModel
                model.formStatus

        CreateAllGroup cagModel ->
            CAG.view
                model.settings.csrftoken
                cagModel
                model.formStatus

        UserProfileForm upfModel pk ->
            UPF.view
                model.settings.csrftoken
                pk
                model.dataStore.userprofiles
                upfModel
                model.formStatus

        ApiSetup maybeKey ->
            ApiSetup.view maybeKey

        Usage ->
            Usage.view



-- filter data for display


filterByMatchedKeyword : String -> { a | matched_keyword : String } -> Bool
filterByMatchedKeyword currentKeyword k =
    k.matched_keyword == currentKeyword


filterBySenderPk : Int -> { a | sender_pk : Maybe Int } -> Bool
filterBySenderPk pk recip =
    pk == Maybe.withDefault 0 recip.sender_pk
