module Views.Menu exposing (menu)

import Html exposing (Html, div, text, i, a)
import Html.Attributes exposing (class, href)
import Messages exposing (Msg)
import Models exposing (Settings, UserProfile)
import Pages exposing (Page(..), FabOnlyPage(..))
import Route exposing (page2loc)
import Views.Helpers exposing (spaLink)


menu : Settings -> Html Msg
menu settings =
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
        div [ class "ui top attached inverted violet menu" ]
            [ itemSpa Home "Home" True
            , div [ class "ui simple dropdown item" ]
                [ text "Menu "
                , i [ class "dropdown icon" ] []
                , div [ class "ui vertical menu" ]
                    [ itemSpa (KeywordTable False) "Keywords" userPerms.can_see_keywords
                    , maybeDivider (isStaff || userPerms.can_see_keywords)
                    , itemSpa (SendAdhoc Nothing Nothing) "Send to Individuals" userPerms.can_send_sms
                    , itemSpa (SendGroup Nothing Nothing) "Send to a Group" userPerms.can_send_sms
                    , itemSpa ScheduledSmsTable "Scheduled Messages" isStaff
                    , maybeDivider (isStaff || userPerms.can_send_sms)
                    , itemSpa (RecipientTable False) "Contacts" userPerms.can_see_contact_names
                    , itemSpa (GroupTable False) "Groups" userPerms.can_see_groups
                    , divider
                    , itemSpa InboundTable "Incoming SMS" userPerms.can_see_incoming
                    , itemSpa OutboundTable "Outgoing SMS" userPerms.can_see_outgoing
                    , divider
                    , lockedItem False "/accounts/password/change" "Change Password" userPerms.user.is_social
                    , item "/accounts/logout/" "Logout" True
                    , divider
                    , div [ class "header" ] [ text settings.twilioFromNumber ]
                    ]
                ]
            , maybeToolsMenu isStaff userPerms
            ]


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
                        [ item (page2loc <| FabOnlyPage EditSiteConfig) "Site Configuration" isStaff
                        , item (page2loc <| FabOnlyPage EditResponses) "Default Responses" isStaff
                        , maybeDivider isStaff
                        , itemSpa UserProfileTable "User Permissions" isStaff
                        , item "/usage/" "Usage Dashboard" isStaff
                        , item "/admin/" "Admin" isStaff
                        , item (page2loc <| FabOnlyPage ApiSetup) "API Setup" isStaff
                        , maybeDivider isStaff
                        , item (page2loc <| FabOnlyPage CreateAllGroup) "Create \"all\" group" isStaff
                        , itemSpa GroupComposer "Compose group" userPerms.can_see_groups
                        , maybeDivider isStaff
                        , div [ class "header" ] [ text "Import" ]
                        , item (page2loc <| FabOnlyPage ContactImport) "CSV" userPerms.can_import
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
