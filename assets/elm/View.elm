module View exposing (view)

import Html exposing (Html, text)
import Messages exposing (..)
import Models exposing (..)
import Pages exposing (Page(..), FabOnlyPage(..))
import Views.AccessDenied as AD
import Views.Curator as C
import Views.ElvantoImport as EI
import Views.Error404 as E404
import Views.Fab as F
import Views.FirstRun as FR
import Views.GroupComposer as GC
import Views.GroupMemberSelect as GMS
import Views.GroupTable as GT
import Views.Home as H
import Views.InboundTable as IT
import Views.KeyRespTable as KRT
import Views.KeywordTable as KT
import Views.OutboundTable as OT
import Views.RecipientTable as RT
import Views.ScheduledSmsTable as SST
import Views.SendAdhoc as SA
import Views.SendGroup as SG
import Views.Shell as Shell
import Views.UserProfileTable as UPT
import Views.Wall as W


view : Model -> Html Msg
view model =
    let
        fab =
            F.view model.dataStore model.page model.fabModel

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
