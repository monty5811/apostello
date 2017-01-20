module Updates.Notification exposing (..)

import Messages exposing (..)
import Models exposing (..)
import Time


update : NotificationMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewNotification type_ text ->
            ( createNotification model text type_, Cmd.none )

        RemoveNotification notif ->
            ( { model | notifications = removeNotification model.notifications notif.id }, Cmd.none )

        CleanOldNotifications t ->
            ( { model | notifications = cleanOldNotifications model.notifications t }, Cmd.none )


getNewId : List Notification -> Int
getNewId notifs =
    notifs
        |> List.map .id
        |> List.maximum
        |> Maybe.withDefault 0
        |> (+) 1


newNotification : List Notification -> Time.Time -> String -> NotificationType -> List Notification
newNotification notifs currentTime text type_ =
    let
        newId =
            getNewId notifs
    in
        (Notification type_ text newId currentTime) :: notifs


removeNotification : List Notification -> Int -> List Notification
removeNotification notifs id =
    notifs
        |> List.filter (\n -> (not (n.id == id)))


cleanOldNotifications : List Notification -> Time.Time -> List Notification
cleanOldNotifications notifs t =
    List.filter (isNewerThan20s t) notifs


isNewerThan20s : Time.Time -> Notification -> Bool
isNewerThan20s t notif =
    (t - notif.created) < (20 * Time.second)


createNotification : Model -> String -> NotificationType -> Model
createNotification model text type_ =
    { model | notifications = newNotification model.notifications model.currentTime text type_ }


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
