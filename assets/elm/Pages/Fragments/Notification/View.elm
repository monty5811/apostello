module Pages.Fragments.Notification.View exposing (view)

import Dict
import Html exposing (Html)
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

        text =
            notification.text
                |> String.split "\n"
                |> List.map Html.text
                |> List.intersperse (Html.br [] [])
    in
    Html.div [ class className ] <|
        [ Html.i
            [ class "close icon"
            , onClick <| NotificationMsg <| RemoveNotification id
            ]
            []
        ]
            ++ text
