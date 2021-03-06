module Pages.Fragments.Menu exposing (allUsersMenuItems, menu)

import Css
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(ScrollToId))
import Models exposing (Settings)
import Pages exposing (Page(..), initSendAdhoc, initSendGroup)
import Pages.DeletePanel as DP
import Pages.ElvantoImport as EI
import Pages.Forms.ContactImport as CI
import Pages.Forms.CreateAllGroup as CAGF
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.SiteConfig as SCF
import Pages.GroupComposer as GC
import Pages.GroupTable as GT
import Pages.InboundTable as IT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.UserProfileTable as UPT
import Route exposing (spaLink)
import Urls


menu : Settings -> List (Html Msg)
menu settings =
    allUsersMenuItems settings


allUsersMenuItems : Settings -> List (Html Msg)
allUsersMenuItems settings =
    let
        userPerms =
            settings.userPerms

        isStaff =
            userPerms.user.is_staff

        item =
            lockedItem isStaff

        itemSpa =
            lockedSpaItem isStaff
    in
    [ menuGroup "Keywords"
        [ isStaff, userPerms.can_see_keywords ]
        [ itemSpa (KeywordTable KT.initialModel False) "Keywords" userPerms.can_see_keywords ]
    , menuGroup "SMS"
        [ isStaff, userPerms.can_send_sms, userPerms.can_see_incoming, userPerms.can_see_outgoing ]
        [ itemSpa (initSendAdhoc Nothing Nothing) "Send to Individuals" userPerms.can_send_sms
        , itemSpa (initSendGroup Nothing Nothing) "Send to a Group" userPerms.can_send_sms
        , itemSpa (InboundTable IT.initialModel) "Incoming SMS" userPerms.can_see_incoming
        , itemSpa (OutboundTable OT.initialModel) "Outgoing SMS" userPerms.can_see_outgoing
        , itemSpa (ScheduledSmsTable SST.initialModel) "Scheduled Messages" isStaff
        ]
    , menuGroup "Contacts"
        [ isStaff, userPerms.can_see_contact_names, userPerms.can_see_groups ]
        [ itemSpa (RecipientTable RT.initialModel False) "Contacts" userPerms.can_see_contact_names
        , itemSpa (GroupTable GT.initialModel False) "Groups" userPerms.can_see_groups
        , itemSpa (CreateAllGroup CAGF.initialModel) "Create \"all\" group" isStaff
        , itemSpa (GroupComposer GC.initialModel) "Compose group" userPerms.can_see_groups
        ]
    , menuGroup "Settings"
        [ isStaff ]
        [ itemSpa (SiteConfigForm SCF.initialModel) "Site Configuration" isStaff
        , itemSpa (DefaultResponsesForm DRF.initialModel) "Default Responses" isStaff
        , itemSpa (UserProfileTable UPT.initialModel) "User Permissions" isStaff
        , itemSpa (DeletePanel DP.initialModel) "Twilio Delete" isStaff
        ]
    , menuGroup "Import"
        [ isStaff, userPerms.can_import ]
        [ itemSpa (ContactImport CI.initialModel) "CSV" userPerms.can_import
        , itemSpa (ElvantoImport EI.initialModel) "Elvanto" userPerms.can_import
        ]
    , menuGroup "Misc"
        [ isStaff ]
        [ itemSpa Usage "Usage Dashboard" isStaff
        , item "/admin/" "Admin" isStaff
        , itemSpa (ApiSetup Nothing) "API Setup" isStaff
        ]
    , menuGroup "Account"
        [ True ]
        [ lockedItem False Urls.account_change_password "Change Password" (not userPerms.user.is_social)
        , item Urls.account_logout "Logout" True
        ]
    , twilioNumber <| Maybe.map .fromNumber settings.twilio
    , Html.div [] []
    , Html.div [] []
    , backToTopButton
    ]


twilioNumber : Maybe String -> Html Msg
twilioNumber maybeNum =
    case maybeNum of
        Nothing ->
            Html.text ""

        Just num ->
            Html.div
                [ Css.mt_4 ]
                [ Html.text <| "Twilio Number: " ++ num
                ]


backToTopButton : Html Msg
backToTopButton =
    Html.div
        [ E.onClick <| ScrollToId "elmContainer"
        , Css.text_sm
        , Css.select_none
        , Css.cursor_pointer
        , Css.lg__hidden
        , Css.btn
        , Css.btn_purple
        , Css.ml_auto
        ]
        [ Html.text "Back to Top" ]


menuGroup : String -> List Bool -> List (Html Msg) -> Html Msg
menuGroup title perms items =
    Html.div [ A.id "menuGroup", Css.mt_4 ]
        [ header title perms
        , Html.ul [ Css.list_reset ] items
        ]


header : String -> List Bool -> Html Msg
header s check =
    if List.foldl (||) False check then
        Html.h4 [] [ Html.text s ]
    else
        Html.text ""


lockedSpaItem : Bool -> Page -> String -> Bool -> Html Msg
lockedSpaItem isStaff page desc perm =
    case isStaff || perm of
        True ->
            Html.li [ Css.pl_2 ] [ spaLink Html.a [] [ Html.text desc ] page ]

        False ->
            Html.text ""


lockedItem : Bool -> String -> String -> Bool -> Html Msg
lockedItem isStaff uri desc perm =
    case isStaff || perm of
        True ->
            Html.li [ Css.pl_2 ] [ Html.a [ A.href uri ] [ Html.text desc ] ]

        False ->
            Html.text ""
