module Pages.Fragments.Menu exposing (menu)

import Data.User exposing (UserProfile)
import Html exposing (Html, a, div, i, text)
import Html.Attributes exposing (class, href)
import Html.Keyed as Keyed
import Messages exposing (Msg)
import Models exposing (Settings)
import Pages exposing (Page(..), initSendAdhoc, initSendGroup)
import Pages.Forms.ContactImport.Model exposing (initialContactImportModel)
import Pages.GroupComposer.Model exposing (initialGroupComposerModel)
import Route exposing (spaLink)
import Store.Model as Store
import Urls


{-
   Use keyed elements so the menu closes when the page changes on mobile.
-}


menu : Page -> Settings -> Store.DataStore -> Html Msg
menu page settings dataStore =
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
    Keyed.node "div"
        [ class "ui top attached inverted violet borderless menu" ]
        [ ( "home", itemSpa Home "Home" True )
        , ( "menu" ++ toString page
          , div [ class "ui simple dropdown item" ]
                [ text "Menu "
                , i [ class "dropdown icon" ] []
                , div [ class "ui vertical menu" ]
                    [ itemSpa (KeywordTable False) "Keywords" userPerms.can_see_keywords
                    , maybeDivider (isStaff || userPerms.can_see_keywords)
                    , itemSpa (initSendAdhoc Nothing Nothing) "Send to Individuals" userPerms.can_send_sms
                    , itemSpa (initSendGroup Nothing Nothing) "Send to a Group" userPerms.can_send_sms
                    , itemSpa ScheduledSmsTable "Scheduled Messages" isStaff
                    , maybeDivider (isStaff || userPerms.can_send_sms)
                    , itemSpa (RecipientTable False) "Contacts" userPerms.can_see_contact_names
                    , itemSpa (GroupTable False) "Groups" userPerms.can_see_groups
                    , divider
                    , itemSpa InboundTable "Incoming SMS" userPerms.can_see_incoming
                    , itemSpa OutboundTable "Outgoing SMS" userPerms.can_see_outgoing
                    , divider
                    , lockedItem False Urls.account_change_password "Change Password" (not userPerms.user.is_social)
                    , item Urls.account_logout "Logout" True
                    , divider
                    , div [ class "header" ] [ text settings.twilioFromNumber ]
                    ]
                ]
          )
        , ( "tools" ++ toString page, maybeToolsMenu isStaff userPerms )
        , ( "loading", loadingIndicator page dataStore )
        ]


loadingIndicator : Page -> Store.DataStore -> Html Msg
loadingIndicator page dataStore =
    let
        spinnerClass =
            if Store.allFinished page dataStore then
                ""
            else if Store.anyFailed page dataStore then
                "red spinner icon"
            else
                "green spinner icon"
    in
    div [ class "right aligned item" ] [ i [ class spinnerClass ] [] ]


maybeToolsMenu : Bool -> UserProfile -> Html Msg
maybeToolsMenu isStaff userPerms =
    let
        item =
            lockedItem isStaff

        itemSpa =
            lockedSpaItem isStaff
    in
    case isStaff || userPerms.can_import of
        True ->
            div [ class "ui simple dropdown item" ]
                [ text "Tools "
                , i [ class "dropdown icon" ] []
                , div [ class "menu" ]
                    [ itemSpa (SiteConfigForm Nothing) "Site Configuration" isStaff
                    , itemSpa (DefaultResponsesForm Nothing) "Default Responses" isStaff
                    , maybeDivider isStaff
                    , itemSpa UserProfileTable "User Permissions" isStaff
                    , itemSpa Usage "Usage Dashboard" isStaff
                    , item "/admin/" "Admin" isStaff
                    , itemSpa (ApiSetup Nothing) "API Setup" isStaff
                    , maybeDivider isStaff
                    , itemSpa (CreateAllGroup "") "Create \"all\" group" isStaff
                    , itemSpa (GroupComposer initialGroupComposerModel) "Compose group" userPerms.can_see_groups
                    , maybeDivider isStaff
                    , div [ class "header" ] [ text "Import" ]
                    , itemSpa (ContactImport initialContactImportModel) "CSV" userPerms.can_import
                    , itemSpa ElvantoImport "Elvanto" userPerms.can_import
                    ]
                ]

        False ->
            text ""


lockedSpaItem : Bool -> Page -> String -> Bool -> Html Msg
lockedSpaItem isStaff page desc perm =
    case isStaff || perm of
        True ->
            spaLink a [ class "item" ] [ text desc ] page

        False ->
            text ""


lockedItem : Bool -> String -> String -> Bool -> Html Msg
lockedItem isStaff uri desc perm =
    case isStaff || perm of
        True ->
            a [ class "item", href uri ] [ text desc ]

        False ->
            text ""


divider : Html Msg
divider =
    div [ class "divider" ] []


maybeDivider : Bool -> Html Msg
maybeDivider show =
    case show of
        True ->
            divider

        False ->
            text ""
