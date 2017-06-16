module Pages.Fragments.Shell exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Messages exposing (Msg)
import Models exposing (Model)
import Pages exposing (Page(..))
import Pages.Fragments.Menu as Menu
import Pages.Fragments.Notification.View as Notif


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
        [ Menu.menu model.page model.settings
        , div [ class "ui hidden divider" ] []
        , div [ class "ui stackable grid container" ]
            [ div [ class "fourteen wide centered column" ]
                (Notif.view model ++ [ mainContent ])
            ]
        , div [ class "ui hidden divider" ] []
        , fab
        ]
