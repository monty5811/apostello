module Pages.Fragments.Notification.View exposing (view)

import Dict
import Html exposing (Html, div, i, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(NotificationMsg), NotificationMsg(RemoveNotification))
import Models exposing (Model)
import Pages.Fragments.Notification.Model exposing (Notification, NotificationType(..))


view : Model -> List (Html Msg)
view model =
    model.notifications
        |> Dict.toList
        |> List.map tView


tView : ( Int, Notification ) -> Html Msg
tView ( id, notification ) =
    let
        messageType =
            case notification.type_ of
                SuccessNotification ->
                    "success"

                WarningNotification ->
                    "warning"

                InfoNotification ->
                    "info"

                ErrorNotification ->
                    "error"

        className =
            "ui floating " ++ messageType ++ " message"
    in
    div [ class className ]
        [ i
            [ class "close icon"
            , onClick <| NotificationMsg <| RemoveNotification id
            ]
            []
        , text notification.text
        ]
