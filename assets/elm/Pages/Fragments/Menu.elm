module Pages.Fragments.Menu exposing (allUsersMenuItems, menu)

import Data exposing (UserProfile)
import Html exposing (Html, a, text)
import Html.Attributes as A exposing (class, href)
import Messages exposing (Msg(WebPushMsg))
import Models exposing (Settings)
import Pages exposing (Page(..), initSendAdhoc, initSendGroup)
import Pages.GroupComposer as GC
import Rocket exposing ((=>))
import Route exposing (spaLink)
import Urls
import WebPush


menu : Settings -> WebPush.Model -> List (Html Msg)
menu settings wp =
    allUsersMenuItems settings wp


allUsersMenuItems : Settings -> WebPush.Model -> List (Html Msg)
allUsersMenuItems settings wp =
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
    [ Html.ul [ A.id "menu" ]
        [ header "Keywords" [ isStaff, userPerms.can_see_keywords ]
        , itemSpa (KeywordTable False) "Keywords" userPerms.can_see_keywords
        , header "SMS" [ isStaff, userPerms.can_send_sms, userPerms.can_see_incoming, userPerms.can_see_outgoing ]
        , itemSpa (initSendAdhoc Nothing Nothing) "Send to Individuals" userPerms.can_send_sms
        , itemSpa (initSendGroup Nothing Nothing) "Send to a Group" userPerms.can_send_sms
        , itemSpa InboundTable "Incoming SMS" userPerms.can_see_incoming
        , itemSpa OutboundTable "Outgoing SMS" userPerms.can_see_outgoing
        , itemSpa ScheduledSmsTable "Scheduled Messages" isStaff
        , header "Contacts" [ isStaff, userPerms.can_see_contact_names, userPerms.can_see_groups ]
        , itemSpa (RecipientTable False) "Contacts" userPerms.can_see_contact_names
        , itemSpa (GroupTable False) "Groups" userPerms.can_see_groups
        , itemSpa (CreateAllGroup "") "Create \"all\" group" isStaff
        , itemSpa (GroupComposer GC.initialModel) "Compose group" userPerms.can_see_groups
        ]
    , Html.ul [ A.id "menu" ]
        [ header "Settings" [ isStaff ]
        , itemSpa (SiteConfigForm Nothing) "Site Configuration" isStaff
        , itemSpa (DefaultResponsesForm Nothing) "Default Responses" isStaff
        , itemSpa UserProfileTable "User Permissions" isStaff
        , header "Import" [ isStaff, userPerms.can_import ]
        , itemSpa (ContactImport "") "CSV" userPerms.can_import
        , itemSpa ElvantoImport "Elvanto" userPerms.can_import
        , header "Misc" [ isStaff ]
        , itemSpa Usage "Usage Dashboard" isStaff
        , item "/admin/" "Admin" isStaff
        , itemSpa (ApiSetup Nothing) "API Setup" isStaff
        , header "Account" [ True ]
        , lockedItem False Urls.account_change_password "Change Password" (not userPerms.user.is_social)
        , item Urls.account_logout "Logout" True
        ]
    , Html.div [ A.id "webpush", A.style [ "margin-left" => "2rem" ] ] <| pushMenu isStaff userPerms wp
    , Html.div [ A.class "text-right", A.style [ "margin-right" => "2rem" ] ]
        [ text <| Maybe.withDefault "" <| Maybe.map .fromNumber settings.twilio
        ]
    ]


pushMenu : Bool -> UserProfile -> WebPush.Model -> List (Html Msg)
pushMenu isStaff perms wp =
    if isStaff || perms.can_see_incoming then
        List.map (Html.map WebPushMsg) (WebPush.view wp)
    else
        [ Html.text "" ]


header : String -> List Bool -> Html Msg
header s check =
    if List.foldl (||) False check then
        Html.li [] [ Html.h4 [ A.style [ "user-select" => "none" ], class "text-left" ] [ text s ] ]
    else
        Html.text ""


lockedSpaItem : Bool -> Page -> String -> Bool -> Html Msg
lockedSpaItem isStaff page desc perm =
    case isStaff || perm of
        True ->
            Html.li [] [ spaLink a [] [ text desc ] page ]

        False ->
            text ""


lockedItem : Bool -> String -> String -> Bool -> Html Msg
lockedItem isStaff uri desc perm =
    case isStaff || perm of
        True ->
            Html.li [] [ a [ href uri ] [ text desc ] ]

        False ->
            text ""
