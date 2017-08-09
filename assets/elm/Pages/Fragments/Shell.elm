module Pages.Fragments.Shell exposing (view)

import Html exposing (Html, div, h3, text)
import Html.Attributes exposing (class, style)
import Messages exposing (Msg)
import Models exposing (Model)
import Pages exposing (Page(..))
import Pages.Fragments.Menu as Menu
import Pages.Fragments.Notification as Notif


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
    div []
        [ Menu.menu model.page model.settings model.dataStore model.webPush
        , div [ class "ui grid container" ]
            [ div [ class "fourteen wide centered column" ] <|
                List.concat
                    [ [ div [ class "ui hidden divider" ] []
                      , h3 [] [ text <| title model.page ]
                      ]
                    , Notif.view model.notifications
                    , [ mainContent ]
                    , [ div [ class "ui hidden divider" ] [] ]
                    ]
            ]
        , div
            [ class "ui mobile hidden tablet hidden visible bottom fixed borderless inverted violet tiny menu"
            , style [ ( "z-index", "auto" ) ]
            ]
          <|
            Menu.allUsersMenuItems model.settings
        , fab
        ]


title : Page -> String
title page =
    case page of
        Home ->
            ""

        AccessDenied ->
            ""

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
            "Edit Profile"

        Help ->
            "Help"

        ContactImport _ ->
            "CSV Import"

        ApiSetup _ ->
            "API Setup"
