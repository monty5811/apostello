module Updates.Notification exposing (..)

import Messages exposing (..)
import Models exposing (..)


update : NotificationMsg -> Model -> Model
update msg model =
    case msg of
        NewNotification type_ text ->
            createNotification model text type_

        RemoveNotification notif ->
            { model | notifications = removeNotification model.notifications notif }


removeNotification : List Notification -> Notification -> List Notification
removeNotification notifs notif =
    notifs
        |> List.filter (\n -> not (n.text == notif.text))


createNotification : Model -> String -> NotificationType -> Model
createNotification model text type_ =
    let
        existing =
            model.notifications |> List.map .text
    in
        case List.member text existing of
            False ->
                { model | notifications = Notification type_ text :: model.notifications }

            True ->
                model


createNotificationFromDjangoMessage : DjangoMessage -> Model -> Model
createNotificationFromDjangoMessage dm model =
    let
        type_ =
            case dm.type_ of
                "info" ->
                    InfoNotification

                "success" ->
                    SuccessNotification

                "warning" ->
                    WarningNotification

                "error" ->
                    ErrorNotification

                _ ->
                    WarningNotification
    in
        createNotification model dm.text type_


createWarningNotification : Model -> String -> Model
createWarningNotification model text =
    createNotification model text WarningNotification


createInfoNotification : Model -> String -> Model
createInfoNotification model text =
    createNotification model text InfoNotification


createSuccessNotification : Model -> String -> Model
createSuccessNotification model text =
    createNotification model text SuccessNotification


createErrorNotification : Model -> String -> Model
createErrorNotification model text =
    createNotification model text ErrorNotification


createNotSavedNotification : Model -> Model
createNotSavedNotification model =
    createWarningNotification model "Something went wrong, there :-( Your changes may not have been saved"


createLoadingFailedNotification : Model -> Model
createLoadingFailedNotification model =
    createWarningNotification model "Something went wrong there when we tried to talk to the server, we'll try again in a bit..."
