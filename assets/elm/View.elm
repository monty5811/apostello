module View exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Messages as M exposing (Msg(FormMsg))
import Models exposing (Model)
import Pages exposing (Page(..), initSendAdhoc)
import Pages.AccessDenied as AD
import Pages.ApiSetup as ApiSetup
import Pages.Curator as C
import Pages.Debug as DG
import Pages.ElvantoImport as EI
import Pages.Error404 as E404
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
import Pages.Fragments.Shell as Shell
import Pages.Fragments.SidePanel as SidePanel
import Pages.GroupComposer as GC
import Pages.GroupTable as GT
import Pages.Help as Help
import Pages.Home as H
import Pages.InboundTable as IT
import Pages.KeyRespTable as KRT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.Usage as Usage
import Pages.UserProfileTable as UPT
import Pages.Wall as W
import RemoteList as RL
import Route exposing (spaLink)
import Store.Messages as S
import Store.Model exposing (filterArchived)


view : Model -> Html Msg
view model =
    let
        sidePanel =
            SidePanel.view model.dataStore
                model.page
                (model.settings.userPerms.can_archive || model.settings.userPerms.user.is_staff)

        shell =
            Shell.view model

        mainContent =
            content model
    in
    shell mainContent sidePanel


content : Model -> Html Msg
content model =
    case model.page of
        OutboundTable ->
            OT.view
                { tableMsg = M.TableMsg
                , tableModel = model.table
                , sms = model.dataStore.outboundSms
                , contactLink = contactToContactLink
                }

        InboundTable ->
            IT.view
                { sms = model.dataStore.inboundSms
                , reprocessSms = \pk -> M.StoreMsg <| S.ReprocessSms pk
                , tableModel = model.table
                , tableMsg = M.TableMsg
                , contactPageLink = smsToContactLink
                , replyPageLink = smsToReplyLink
                , keywordFormLink = smsToKeywordLink
                }

        GroupTable viewingArchive ->
            GT.view
                { tableModel = model.table
                , tableMsg = M.TableMsg
                , groups = filterArchived viewingArchive model.dataStore.groups
                , toggleArchiveGroup = \b pk -> M.StoreMsg <| S.ToggleGroupArchive b pk
                , groupFormLink = \grp -> spaLink Html.a [] [ Html.text grp.name ] <| GroupForm GF.initialModel <| Just grp.pk
                }

        GroupComposer composerModel ->
            GC.view
                { form = M.GroupComposerMsg
                , loadData = M.StoreMsg S.LoadData
                , groupLink = \x -> spaLink Html.a [ A.class "float-right button" ] [ Html.text "Send a Message" ] <| initSendAdhoc Nothing x
                }
                composerModel
                (filterArchived False model.dataStore.groups)

        RecipientTable viewingArchive ->
            RT.view
                { tableMsg = M.TableMsg
                , tableModel = model.table
                , recipients = filterArchived viewingArchive model.dataStore.recipients
                , toggleRecipientArchive = \b pk -> M.StoreMsg <| S.ToggleRecipientArchive b pk
                , contactLink = contactToContactLink
                }

        KeywordTable viewingArchive ->
            KT.view
                { tableMsg = M.TableMsg
                , tableModel = model.table
                , keywords = filterArchived viewingArchive model.dataStore.keywords
                , toggleKeywordArchive = \b pk -> M.StoreMsg <| S.ToggleKeywordArchive b pk
                , keywordLink = keywordToKeywordLink
                , keywordRespLink = keywordToKeywordRespLink
                }

        ElvantoImport ->
            EI.view
                { tableMsg = M.TableMsg
                , topMsg = M.ElvantoMsg
                , toggleElvantoGroupSync = M.StoreMsg << S.ToggleElvantoGroupSync
                }
                model.table
                model.dataStore.elvantoGroups

        Wall ->
            W.view (model.dataStore.inboundSms |> filterArchived False |> RL.filter (\s -> s.display_on_wall))

        Curator ->
            C.view
                { tableMsg = M.TableMsg
                , sms = model.dataStore.inboundSms |> filterArchived False
                , tableModel = model.table
                , toggleWallDisplay = \b p -> M.StoreMsg <| S.ToggleWallDisplay b p
                }

        UserProfileTable ->
            UPT.view
                { tableMsg = M.TableMsg
                , tableModel = model.table
                , profiles = model.dataStore.userprofiles
                , userProfileLink =
                    \up ->
                        spaLink Html.a
                            []
                            [ Html.text up.user.email ]
                            (UserProfileForm UPF.initialModel up.user.pk)
                , toggleField = M.StoreMsg << S.ToggleProfileField
                }

        ScheduledSmsTable ->
            SST.view
                { tableMsg = M.TableMsg
                , tableModel = model.table
                , currentTime = model.currentTime
                , sms = model.dataStore.queuedSms
                , contactLink = contactToContactLink
                , groupLink = groupToGroupLink
                , cancelSms = M.StoreMsg << S.CancelSms
                }

        KeyRespTable keyRespModel viewingArchive currentKeyword ->
            KRT.view
                { form = M.KeyRespTableMsg
                , tableMsg = M.TableMsg
                , toggleDealtWith = \x y -> M.StoreMsg <| S.ToggleInboundSmsDealtWith x y
                , toggleInboundSmsArchive = \x y -> M.StoreMsg <| S.ToggleInboundSmsArchive x y
                , pkToReplyLink = smsToReplyLink
                , pkToContactLink = smsToContactLink
                }
                viewingArchive
                model.table
                (model.dataStore.inboundSms |> filterArchived viewingArchive |> RL.filter (filterByMatchedKeyword currentKeyword))
                keyRespModel
                currentKeyword

        FirstRun m ->
            Html.map M.FirstRunMsg <| FR.view m

        Debug m ->
            Html.map M.DebugMsg <| DG.view m

        AccessDenied ->
            AD.view

        SendAdhoc saModel ->
            SAF.view
                { form = FormMsg << M.SendAdhocMsg
                , postForm = M.FormMsg M.PostSendAdhocForm
                , smsCharLimit = model.settings.smsCharLimit
                , newContactButton = spaLink Html.a [ A.class "button" ] [ Html.text "Add a New Contact" ] <| ContactForm CF.initialModel Nothing
                }
                saModel
                (filterArchived False model.dataStore.recipients)
                model.formStatus

        SendGroup sgModel ->
            SGF.view
                { form = M.FormMsg << M.SendGroupMsg
                , postForm = M.FormMsg M.PostSendGroupForm
                , smsCharLimit = model.settings.smsCharLimit
                , newGroupButton = spaLink Html.a [ A.class "button" ] [ Html.text "Create a New Group" ] <| GroupForm GF.initialModel Nothing
                }
                sgModel
                (filterArchived False model.dataStore.groups |> RL.filter (\x -> x.cost > 0))
                model.formStatus

        Error404 ->
            E404.view

        Home ->
            H.view (spaLink Html.a [] [ Html.text "FAQs/Help" ] Help)

        Help ->
            Help.view

        ContactImport _ ->
            CI.view
                { post = FormMsg M.PostContactImportForm, form = FormMsg << M.ContactImportMsg }
                model.formStatus

        GroupForm gfModel maybePk ->
            GF.view
                { form = M.FormMsg << M.GroupFormMsg
                , postForm = M.FormMsg M.PostGroupForm
                , noop = M.Nope
                , toggleGroupMembership = \x y -> M.StoreMsg <| S.ToggleGroupMembership x y
                , restoreGroupLink = \x -> spaLink Html.a [] [ Html.text "Archived Group" ] <| GroupForm GF.initialModel x
                }
                maybePk
                model.dataStore.groups
                gfModel
                model.formStatus

        ContactForm cfModel maybePk ->
            let
                canSeeContactNum =
                    model.settings.userPerms.can_see_contact_nums || model.settings.userPerms.user.is_staff

                canSeeContactNotes =
                    model.settings.userPerms.can_see_contact_notes || model.settings.userPerms.user.is_staff

                incomingTable =
                    case maybePk of
                        Nothing ->
                            Nothing

                        Just pk ->
                            Just <|
                                IT.view
                                    { sms = model.dataStore.inboundSms |> RL.filter (filterBySenderPk pk)
                                    , reprocessSms = \pk -> M.StoreMsg <| S.ReprocessSms pk
                                    , tableModel = model.table
                                    , tableMsg = M.TableMsg
                                    , contactPageLink = smsToContactLink
                                    , replyPageLink = smsToReplyLink
                                    , keywordFormLink = smsToKeywordLink
                                    }
            in
            CF.view
                { postForm = FormMsg <| M.PostContactForm canSeeContactNum canSeeContactNotes
                , c = FormMsg << M.ContactFormMsg
                , noop = M.Nope
                , spa = \x -> spaLink Html.a [] [ Html.text "Archived Contact" ] <| ContactForm CF.initialModel x
                , defaultNumberPrefix = model.settings.defaultNumberPrefix
                , canSeeContactNum = canSeeContactNum
                , canSeeContactNotes = canSeeContactNotes
                }
                incomingTable
                maybePk
                model.dataStore.recipients
                cfModel
                model.formStatus

        KeywordForm kfModel maybeK ->
            KF.view
                { postForm = FormMsg M.PostKeywordForm
                , k = FormMsg << M.KeywordFormMsg
                , noop = M.Nope
                , spa = \x -> spaLink Html.a [] [ Html.text "Archived Keyword" ] <| KeywordForm KF.initialModel x
                }
                model.dataStore.keywords
                (filterArchived False model.dataStore.groups)
                model.dataStore.users
                maybeK
                kfModel
                model.formStatus

        SiteConfigForm scModel ->
            SCF.view
                { postForm = FormMsg M.PostSiteConfigForm, form = FormMsg << M.SiteConfigFormMsg }
                (filterArchived False model.dataStore.groups)
                scModel
                model.formStatus

        DefaultResponsesForm drModel ->
            DRF.view
                { postForm = FormMsg M.PostDefaultRespForm, form = FormMsg << M.DefaultResponsesFormMsg }
                drModel
                model.formStatus

        CreateAllGroup cagModel ->
            CAG.view
                { postForm = FormMsg M.PostCreateAllGroupForm, form = FormMsg << M.CreateAllGroupMsg }
                cagModel
                model.formStatus

        UserProfileForm upfModel pk ->
            UPF.view
                { postForm = FormMsg M.PostUserProfileForm, form = FormMsg << M.UserProfileFormMsg }
                pk
                model.dataStore.userprofiles
                upfModel
                model.formStatus

        ApiSetup maybeKey ->
            Html.map M.ApiSetupMsg <| ApiSetup.view maybeKey

        Usage ->
            Usage.view



-- filter data for display


filterByMatchedKeyword : String -> { a | matched_keyword : String } -> Bool
filterByMatchedKeyword currentKeyword k =
    k.matched_keyword == currentKeyword


filterBySenderPk : Int -> { a | sender_pk : Maybe Int } -> Bool
filterBySenderPk pk recip =
    pk == Maybe.withDefault 0 recip.sender_pk


smsToReplyLink : { a | sender_pk : Maybe Int } -> Html Msg
smsToReplyLink sms =
    spaLink Html.a
        []
        [ Html.i [ A.class "fa fa-reply" ] [] ]
        (initSendAdhoc Nothing <| Maybe.map List.singleton sms.sender_pk)


smsToContactLink : { a | sender_name : String, sender_pk : Maybe Int } -> Html Msg
smsToContactLink sms =
    spaLink Html.a
        [ A.style [ ( "color", "var(--color-black)" ) ] ]
        [ Html.text sms.sender_name ]
        (ContactForm CF.initialModel sms.sender_pk)


smsToKeywordLink : { a | matched_keyword : String } -> Html Msg
smsToKeywordLink sms =
    spaLink Html.a
        [ A.style [ ( "color", "#212121" ) ] ]
        [ Html.text sms.matched_keyword ]
        (KeywordForm KF.initialModel <| Just sms.matched_keyword)


contactToContactLink : { a | full_name : String, pk : Int } -> Html Msg
contactToContactLink contact =
    spaLink Html.a [] [ Html.text contact.full_name ] <| ContactForm CF.initialModel <| Just contact.pk


groupToGroupLink : { a | name : String, pk : Int } -> Html Msg
groupToGroupLink group =
    spaLink Html.a [] [ Html.text group.name ] <| GroupForm GF.initialModel <| Just group.pk


keywordToKeywordRespLink :
    ({ a | is_archived : Bool, keyword : String } -> String)
    -> { a | is_archived : Bool, keyword : String }
    -> Html Msg
keywordToKeywordRespLink fn keyword =
    spaLink Html.a [] [ Html.text <| fn keyword ] <| KeyRespTable False keyword.is_archived keyword.keyword


keywordToKeywordLink : { a | keyword : String } -> Html Msg
keywordToKeywordLink keyword =
    spaLink Html.a [ A.class "button" ] [ Html.text "Edit" ] (KeywordForm KF.initialModel <| Just keyword.keyword)
