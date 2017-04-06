module View exposing (view)

import Html exposing (Html, text)
import Messages exposing (Msg)
import Models exposing (Model)
import Pages exposing (Page(..), FabOnlyPage(..))
import View.AccessDenied as AD
import View.Curator as C
import View.ElvantoImport as EI
import View.Error404 as E404
import View.Fab as F
import View.FirstRun as FR
import View.GroupComposer as GC
import View.GroupMemberSelect as GMS
import View.GroupTable as GT
import View.Home as H
import View.InboundTable as IT
import View.KeyRespTable as KRT
import View.KeywordTable as KT
import View.OutboundTable as OT
import View.RecipientTable as RT
import View.ScheduledSmsTable as SST
import View.SendAdhoc as SA
import View.SendGroup as SG
import View.Shell as Shell
import View.UserProfileTable as UPT
import View.Wall as W


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
            OT.view model.filterRegex model.dataStore.outboundSms

        InboundTable ->
            IT.view model.filterRegex model.dataStore.inboundSms

        GroupTable viewingArchive ->
            GT.view model.filterRegex (filterArchived viewingArchive model.dataStore.groups)

        GroupComposer ->
            GC.view model.groupComposer (filterArchived False model.dataStore.groups)

        RecipientTable viewingArchive ->
            RT.view model.filterRegex <| filterArchived viewingArchive model.dataStore.recipients

        KeywordTable viewingArchive ->
            KT.view model.filterRegex <| filterArchived viewingArchive model.dataStore.keywords

        ElvantoImport ->
            EI.view model.filterRegex model.dataStore.elvantoGroups

        Wall ->
            W.view (model.dataStore.inboundSms |> filterArchived False |> List.filter (\s -> s.display_on_wall))

        Curator ->
            C.view model.filterRegex (model.dataStore.inboundSms |> filterArchived False)

        UserProfileTable ->
            UPT.view model.filterRegex model.dataStore.userprofiles

        ScheduledSmsTable ->
            SST.view model.filterRegex model.currentTime model.dataStore.queuedSms

        KeyRespTable viewingArchive currentKeyword ->
            KRT.view viewingArchive
                model.filterRegex
                (model.dataStore.inboundSms |> filterArchived viewingArchive |> filterByMatchedKeyword currentKeyword)
                model.keyRespTable
                currentKeyword

        FirstRun ->
            FR.view model.firstRun

        AccessDenied ->
            AD.view

        SendAdhoc _ _ ->
            SA.view model.loadingStatus model.settings model.sendAdhoc <| filterArchived False model.dataStore.recipients

        SendGroup _ _ ->
            SG.view model.loadingStatus model.settings model.sendGroup <|
                List.filter (\x -> x.cost > 0) <|
                    filterArchived False model.dataStore.groups

        Error404 ->
            E404.view

        Home ->
            H.view

        EditGroup pk ->
            GMS.view (model.dataStore.groups |> List.filter (\x -> x.pk == pk) |> List.head) model.groupSelect

        EditContact pk ->
            IT.view model.filterRegex (model.dataStore.inboundSms |> filterBySenderPk pk)

        FabOnlyPage _ ->
            text ""



-- filter data for display


filterArchived : Bool -> List { a | is_archived : Bool } -> List { a | is_archived : Bool }
filterArchived viewingArchive data =
    data
        |> List.filter (\x -> x.is_archived == viewingArchive)


filterByMatchedKeyword : String -> List { a | matched_keyword : String } -> List { a | matched_keyword : String }
filterByMatchedKeyword currentKeyword data =
    data
        |> List.filter (\x -> x.matched_keyword == currentKeyword)


filterBySenderPk : Int -> List { a | sender_pk : Maybe Int } -> List { a | sender_pk : Maybe Int }
filterBySenderPk pk data =
    data
        |> List.filter (\x -> Maybe.withDefault 0 x.sender_pk == pk)
