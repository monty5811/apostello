module View exposing (view)

import Css
import Html exposing (Html)
import Html.Attributes as A
import Messages as M exposing (Msg)
import Models exposing (Model)
import Pages exposing (Page(..), initSendAdhoc)
import Pages.AccessDenied as AD
import Pages.ApiSetup as ApiSetup
import Pages.Curator as C
import Pages.Debug as DG
import Pages.DeletePanel as DP
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
import Pages.Fragments.ActionsPanel as ActionsPanel
import Pages.Fragments.Shell as Shell
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
            ActionsPanel.view model.dataStore
                model.page
                (model.settings.userPerms.can_archive || model.settings.userPerms.user.is_staff)

        mainContent =
            content model
    in
    Shell.view model mainContent sidePanel


content : Model -> Html Msg
content model =
    case model.page of
        OutboundTable otModel ->
            OT.view
                { tableMsg = OT.TableMsg >> M.OutboundTableMsg
                , sms = model.dataStore.outboundSms
                , contactLink = contactToContactLink
                }
                otModel

        InboundTable itModel ->
            IT.view
                { tableMsg = IT.TableMsg >> M.InboundTableMsg
                , sms = model.dataStore.inboundSms
                , reprocessSms = \pk -> M.StoreMsg <| S.ReprocessSms pk
                , contactPageLink = smsToContactLink
                , replyPageLink = smsToReplyLink
                , keywordFormLink = smsToKeywordLink
                }
                itModel

        GroupTable gtModel viewingArchive ->
            GT.view
                { tableMsg = GT.TableMsg >> M.GroupTableMsg
                , groups = filterArchived viewingArchive model.dataStore.groups
                , toggleArchiveGroup = \b pk -> M.StoreMsg <| S.ToggleGroupArchive b pk
                , groupFormLink = groupToGroupLink
                }
                gtModel

        GroupComposer composerModel ->
            GC.view
                { form = M.GroupComposerMsg
                , groupLink = \x -> spaLink Html.a [ Css.float_right ] [ Html.text "Send a Message" ] <| initSendAdhoc Nothing x
                }
                composerModel
                (filterArchived False model.dataStore.groups)

        RecipientTable rtModel viewingArchive ->
            RT.view
                { tableMsg = RT.TableMsg >> M.RecipientTableMsg
                , recipients = filterArchived viewingArchive model.dataStore.recipients
                , toggleRecipientArchive = \b pk -> M.StoreMsg <| S.ToggleRecipientArchive b pk
                , contactLink = contactToContactLink
                }
                rtModel

        KeywordTable ktModel viewingArchive ->
            KT.view
                { tableMsg = KT.TableMsg >> M.KeywordTableMsg
                , keywords = filterArchived viewingArchive model.dataStore.keywords
                , toggleKeywordArchive = \b pk -> M.StoreMsg <| S.ToggleKeywordArchive b pk
                , keywordLink = keywordToKeywordLink
                , keywordRespLink = keywordToKeywordRespLink
                }
                ktModel

        ElvantoImport eiModel ->
            EI.view
                { topMsg = M.ElvantoMsg
                , tableMsg = EI.TableMsg >> M.ElvantoMsg
                , toggleElvantoGroupSync = M.StoreMsg << S.ToggleElvantoGroupSync
                , groups = model.dataStore.elvantoGroups
                }
                eiModel

        Wall ->
            W.view (model.dataStore.inboundSms |> filterArchived False |> RL.filter (\s -> s.display_on_wall))

        Curator cModel ->
            C.view
                { tableMsg = C.TableMsg >> M.CuratorMsg
                , sms = model.dataStore.inboundSms |> filterArchived False
                , toggleWallDisplay = \b p -> M.StoreMsg <| S.ToggleWallDisplay b p
                }
                cModel

        UserProfileTable uptModel ->
            UPT.view
                { tableMsg = UPT.TableMsg >> M.UserProfileTableMsg
                , profiles = model.dataStore.userprofiles
                , userProfileLink =
                    \up ->
                        spaLink Html.a
                            []
                            [ Html.text up.user.email ]
                            (UserProfileForm <| UPF.initialModel up.user.pk)
                , toggleField = M.StoreMsg << S.ToggleProfileField
                }
                uptModel

        ScheduledSmsTable sstModel ->
            SST.view
                { tableMsg = SST.TableMsg >> M.ScheduledSmsTableMsg
                , currentTime = model.currentTime
                , sms = model.dataStore.queuedSms
                , contactLink = contactToContactLink
                , groupLink = groupToGroupLink
                , cancelSms = M.StoreMsg << S.CancelSms
                }
                sstModel

        KeyRespTable keyRespModel viewingArchive currentKeyword ->
            KRT.view
                { tableMsg = KRT.TableMsg >> M.KeyRespTableMsg
                , form = M.KeyRespTableMsg
                , toggleDealtWith = \x y -> M.StoreMsg <| S.ToggleInboundSmsDealtWith x y
                , toggleInboundSmsArchive = \x y -> M.StoreMsg <| S.ToggleInboundSmsArchive x y
                , pkToReplyLink = smsToReplyLink
                , pkToContactLink = smsToContactLink
                }
                viewingArchive
                (model.dataStore.inboundSms |> filterArchived viewingArchive |> RL.filter (filterByMatchedKeyword currentKeyword))
                currentKeyword
                keyRespModel

        FirstRun m ->
            Html.map M.FirstRunMsg <| FR.view m

        Debug m ->
            Html.map M.DebugMsg <| DG.view m

        AccessDenied ->
            AD.view

        SendAdhoc saModel ->
            SAF.view
                { form = M.SendAdhocMsg << SAF.InputMsg
                , postForm = M.SendAdhocMsg SAF.PostForm
                , smsCharLimit = model.settings.smsCharLimit
                , twilioCost =
                    model.settings.twilio
                        |> Maybe.map .sendingCost
                        |> Maybe.withDefault 0.0
                , newContactButton = spaLink Html.a [] [ Html.text "Add a New Contact" ] <| ContactForm <| CF.initialModel Nothing
                , contacts = filterArchived False model.dataStore.recipients |> RL.filter (.never_contact >> not)
                }
                saModel

        SendGroup sgModel ->
            SGF.view
                { form = M.SendGroupMsg << SGF.InputMsg
                , postForm = M.SendGroupMsg SGF.PostForm
                , smsCharLimit = model.settings.smsCharLimit
                , newGroupButton = spaLink Html.a [] [ Html.text "Create a New Group" ] <| GroupForm <| GF.initialModel Nothing
                , groups = filterArchived False model.dataStore.groups |> RL.filter (\x -> x.cost > 0)
                }
                sgModel

        Error404 ->
            E404.view

        Home ->
            H.view (spaLink Html.a [] [ Html.text "FAQs/Help" ] Help)

        Help ->
            Help.view

        ContactImport ciModel ->
            CI.view
                { form = M.ContactImportMsg }
                ciModel

        GroupForm gfModel ->
            GF.view
                { form = M.GroupFormMsg << GF.InputMsg
                , postForm = M.GroupFormMsg GF.PostForm
                , noop = M.Nope
                , toggleGroupMembership = \x y -> M.StoreMsg <| S.ToggleGroupMembership x y
                , restoreGroupLink = \x -> spaLink Html.a [] [ Html.text "Archived Group" ] <| GroupForm <| GF.initialModel x
                , groups = model.dataStore.groups
                }
                gfModel

        ContactForm cfModel ->
            let
                canSeeContactNum =
                    model.settings.userPerms.can_see_contact_nums || model.settings.userPerms.user.is_staff

                canSeeContactNotes =
                    model.settings.userPerms.can_see_contact_notes || model.settings.userPerms.user.is_staff

                incomingTable =
                    case cfModel.maybePk of
                        Nothing ->
                            Nothing

                        Just pk ->
                            Just <|
                                IT.view
                                    { tableMsg = CF.TableMsg >> M.ContactFormMsg
                                    , sms = model.dataStore.inboundSms |> RL.filter (filterBySenderPk pk)
                                    , reprocessSms = M.StoreMsg << S.ReprocessSms
                                    , contactPageLink = smsToContactLink
                                    , replyPageLink = smsToReplyLink
                                    , keywordFormLink = smsToKeywordLink
                                    }
                                    { tableModel = cfModel.tableModel }
            in
            CF.view
                { postForm = M.ContactFormMsg <| CF.PostForm canSeeContactNum canSeeContactNotes
                , c = M.ContactFormMsg << CF.InputMsg
                , noop = M.Nope
                , spa = \x -> spaLink Html.a [] [ Html.text "Archived Contact" ] <| ContactForm <| CF.initialModel x
                , defaultNumberPrefix = model.settings.defaultNumberPrefix
                , canSeeContactNum = canSeeContactNum
                , canSeeContactNotes = canSeeContactNotes
                }
                incomingTable
                model.dataStore.recipients
                cfModel

        KeywordForm kfModel ->
            KF.view
                { postForm = M.KeywordFormMsg KF.PostForm
                , inputChange = M.KeywordFormMsg << KF.InputMsg
                , noop = M.Nope
                , spa = \x -> spaLink Html.a [] [ Html.text "Archived Keyword" ] <| KeywordForm <| KF.initialModel x
                }
                model.dataStore.keywords
                (filterArchived False model.dataStore.groups)
                model.dataStore.users
                kfModel

        SiteConfigForm scModel ->
            SCF.view
                { postForm = M.SiteConfigFormMsg SCF.PostForm
                , form = M.SiteConfigFormMsg << SCF.InputMsg
                }
                (filterArchived False model.dataStore.groups)
                scModel

        DefaultResponsesForm drModel ->
            DRF.view
                { postForm = M.DefaultResponsesFormMsg DRF.PostForm
                , form = M.DefaultResponsesFormMsg << DRF.InputMsg
                }
                drModel

        CreateAllGroup cagModel ->
            CAG.view
                { form = M.CreateAllGroupMsg }
                cagModel

        UserProfileForm upfModel ->
            UPF.view
                { postForm = M.UserProfileFormMsg UPF.PostForm
                , inputChange = M.UserProfileFormMsg << UPF.InputMsg
                }
                upfModel

        ApiSetup maybeKey ->
            Html.map M.ApiSetupMsg <| ApiSetup.view maybeKey

        DeletePanel dpModel ->
            Html.map M.DeletePanelMsg <|
                DP.view
                    { inboundSms = model.dataStore.inboundSms
                    , outboundSms = model.dataStore.outboundSms
                    }
                    dpModel

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
        []
        [ Html.text sms.sender_name ]
        (ContactForm <| CF.initialModel sms.sender_pk)


smsToKeywordLink : { a | matched_keyword : String } -> Html Msg
smsToKeywordLink sms =
    spaLink Html.a
        []
        [ Html.text sms.matched_keyword ]
        (KeywordForm <| KF.initialModel <| Just sms.matched_keyword)


contactToContactLink : { a | full_name : String, pk : Int } -> Html Msg
contactToContactLink contact =
    spaLink Html.a [] [ Html.text contact.full_name ] <| ContactForm <| CF.initialModel (Just contact.pk)


groupToGroupLink : { a | name : String, pk : Int } -> Html Msg
groupToGroupLink group =
    spaLink Html.a [] [ Html.text group.name ] <| GroupForm <| GF.initialModel <| Just group.pk


keywordToKeywordRespLink :
    ({ a | is_archived : Bool, keyword : String } -> String)
    -> { a | is_archived : Bool, keyword : String }
    -> Html Msg
keywordToKeywordRespLink fn keyword =
    spaLink Html.a [] [ Html.text <| fn keyword ] <| KeyRespTable KRT.initialModel keyword.is_archived keyword.keyword


keywordToKeywordLink : { a | keyword : String } -> Html Msg
keywordToKeywordLink keyword =
    spaLink Html.a [ Css.btn, Css.btn_purple ] [ Html.text "Edit" ] (KeywordForm <| KF.initialModel <| Just keyword.keyword)
