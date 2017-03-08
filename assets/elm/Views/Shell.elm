module Views.Shell exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Messages exposing (..)
import Models exposing (..)
import Views.Menu
import Views.Notification as Notif


view : Model -> Html Msg -> Html Msg -> Html Msg
view model mainContent fab =
    case model.page of
        Home ->
            commonShell model mainContent fab

        Wall ->
            mainContent

        OutboundTable ->
            commonShell model mainContent fab

        InboundTable ->
            commonShell model mainContent fab

        GroupTable viewingArchive ->
            commonShell model mainContent fab

        GroupComposer ->
            commonShell model mainContent fab

        RecipientTable _ ->
            commonShell model mainContent fab

        KeywordTable _ ->
            commonShell model mainContent fab

        ElvantoImport ->
            commonShell model mainContent fab

        Curator ->
            commonShell model mainContent fab

        UserProfileTable ->
            commonShell model mainContent fab

        ScheduledSmsTable ->
            commonShell model mainContent fab

        KeyRespTable _ _ ->
            commonShell model mainContent fab

        FirstRun ->
            mainContent

        AccessDenied ->
            commonShell model mainContent fab

        SendAdhoc _ _ ->
            commonShell model mainContent fab

        SendGroup _ _ ->
            commonShell model mainContent fab

        Error404 ->
            commonShell model mainContent fab

        EditGroup _ ->
            div [] [ mainContent, fab ]

        EditContact _ ->
            div [] [ mainContent, fab ]

        FabOnlyPage _ ->
            fab


commonShell : Model -> Html Msg -> Html Msg -> Html Msg
commonShell model mainContent fab =
    div []
        [ Views.Menu.menu model.settings
        , div [ class "ui hidden divider" ] []
        , div [ class "ui stackable grid container" ]
            [ div [ class "fourteen wide centered column" ]
                ((Notif.view model) ++ [ mainContent ])
            ]
        , div [ class "ui hidden divider" ] []
        , fab
        ]
