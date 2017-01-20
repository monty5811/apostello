module Views.Notification exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)


view : Model -> List (Html Msg)
view model =
    List.map tView model.notifications


tView : Notification -> Html Msg
tView notification =
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
            [ i [ class "close icon", onClick (NotificationMsg (RemoveNotification notification)) ] []
            , text notification.text
            ]
