module Pages.Fragments.Shell exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Messages exposing (Msg)
import Models exposing (Model)
import Pages exposing (FabOnlyPage(..), Page(..))
import Pages.Fragments.Menu as Menu
import Pages.Fragments.Notification.View as Notif


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

        GroupTable _ ->
            commonShell model mainContent fab

        GroupComposer _ ->
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

        KeyRespTable _ _ _ ->
            commonShell model mainContent fab

        FirstRun _ ->
            mainContent

        AccessDenied ->
            commonShell model mainContent fab

        SendAdhoc _ ->
            commonShell model mainContent fab

        SendGroup _ ->
            commonShell model mainContent fab

        Error404 ->
            commonShell model mainContent fab

        GroupForm _ _ ->
            commonShell model mainContent fab

        ContactForm _ _ ->
            commonShell model mainContent fab

        KeywordForm _ _ ->
            commonShell model mainContent fab

        SiteConfigForm _ ->
            commonShell model mainContent fab

        FabOnlyPage _ ->
            fab


commonShell : Model -> Html Msg -> Html Msg -> Html Msg
commonShell model mainContent fab =
    div []
        [ Menu.menu model.page model.settings
        , div [ class "ui hidden divider" ] []
        , div [ class "ui stackable grid container" ]
            [ div [ class "fourteen wide centered column" ]
                (Notif.view model ++ [ mainContent ])
            ]
        , div [ class "ui hidden divider" ] []
        , fab
        ]
