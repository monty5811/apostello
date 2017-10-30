module Pages.Fragments.Shell exposing (view)

import Html exposing (Html, div, h3, text)
import Html.Attributes exposing (class, id)
import Html.Events as E
import Messages exposing (Msg(NotificationMsg, ToggleMenu))
import Models exposing (MenuModel(MenuHidden, MenuVisible), Model)
import Notification as Notif
import Pages exposing (Page(..))
import Pages.Fragments.Menu as Menu
import Route exposing (spaLink)


view : Model -> Html Msg -> Html Msg -> Html Msg
view model mainContent fab =
    case model.page of
        Wall ->
            mainContent

        Usage ->
            mainContent

        FirstRun _ ->
            mainContent

        _ ->
            commonShell model mainContent fab


commonShell : Model -> Html Msg -> Html Msg -> Html Msg
commonShell model mainContent fab =
    Html.div
        []
        [ Html.header [ id "head", class "text-center" ]
            [ case model.page of
                Home ->
                    Html.h2 [] [ text "apostello" ]

                _ ->
                    spaLink Html.a [] [ Html.h2 [] [ text "apostello" ] ] Home
            , Html.a [ class "button bounce", E.onClick ToggleMenu ] [ text "Menu" ]
            ]
        , Html.main_ [ id "wrap" ]
            [ fab
            , div [ id "content" ] <|
                List.concat
                    [ [ h3 [] [ text <| title model.page ] ]
                    , List.map (Html.map NotificationMsg) (Notif.view model.notifications)
                    , [ mainContent ]
                    ]
            ]
        , div [ id "menuWrapper", class <| menuClass model.menuState ] <|
            Html.a
                [ class "button button-lg"
                , id "close"
                , E.onClick ToggleMenu
                ]
                [ text "Close" ]
                :: Menu.menu model.settings model.webPush
        ]


menuClass : MenuModel -> String
menuClass menuState =
    case menuState of
        MenuVisible ->
            "menuVisible"

        MenuHidden ->
            "menuHidden"


title : Page -> String
title page =
    case page of
        Home ->
            ""

        AccessDenied ->
            ""

        Debug _ ->
            "Debug Configuration"

        ContactForm _ (Just _) ->
            "Edit Contact"

        ContactForm _ Nothing ->
            "New Contact"

        CreateAllGroup _ ->
            ""

        Curator ->
            "Wall Curator"

        ElvantoImport ->
            "Elvanto Sync"

        Error404 ->
            ""

        FirstRun _ ->
            ""

        GroupComposer _ ->
            ""

        GroupForm _ (Just _) ->
            "Edit Group"

        GroupForm _ Nothing ->
            "New Group"

        GroupTable True ->
            "Groups (archived)"

        GroupTable False ->
            "Groups"

        InboundTable ->
            "Incoming"

        KeyRespTable _ True k ->
            k ++ " reponses (archived)"

        KeyRespTable _ False k ->
            k ++ " reponses"

        KeywordForm _ (Just _) ->
            "Edit Keyword"

        KeywordForm _ Nothing ->
            "New Keyword"

        KeywordTable False ->
            "Keywords"

        KeywordTable True ->
            "Keywords (archived)"

        OutboundTable ->
            "Outgoing"

        RecipientTable False ->
            "Contacts"

        RecipientTable True ->
            "Contacts (archived)"

        ScheduledSmsTable ->
            "Scheduled"

        SendAdhoc _ ->
            "Send"

        SendGroup _ ->
            "Send"

        UserProfileTable ->
            "Permissions"

        Wall ->
            ""

        SiteConfigForm _ ->
            "Configuration"

        DefaultResponsesForm _ ->
            "Default Responses"

        Usage ->
            ""

        UserProfileForm _ _ ->
            ""

        Help ->
            "Help"

        ContactImport _ ->
            "CSV Import"

        ApiSetup _ ->
            "API Setup"
