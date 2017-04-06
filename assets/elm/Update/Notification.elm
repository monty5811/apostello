module Update.Notification exposing (..)

import Dict
import Messages
    exposing
        ( Msg(NotificationMsg)
        , NotificationMsg(RemoveNotification)
        )
import Models exposing (Model, NotificationType(..), Notification)
import Models.DjangoMessage exposing (DjangoMessage)
import Process
import Time
import Task


delayAction : Time.Time -> msg -> Cmd msg
delayAction t msg =
    Process.sleep t
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


update : NotificationMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        RemoveNotification id ->
            ( { model | notifications = remove id model.notifications }, [] )


remove : Int -> Dict.Dict Int Notification -> Dict.Dict Int Notification
remove id notifications =
    Dict.remove id notifications


create : Model -> String -> NotificationType -> ( Model, Cmd Msg )
create model text type_ =
    let
        maxId =
            model.notifications
                |> Dict.keys
                |> List.maximum
                |> Maybe.withDefault 0

        newNotifications =
            Dict.insert (maxId + 1) (Notification type_ text) model.notifications
    in
        ( { model | notifications = newNotifications }
        , delayAction (20 * Time.second) <| NotificationMsg <| RemoveNotification (maxId + 1)
        )


createFromDjangoMessage : DjangoMessage -> Model -> ( Model, Cmd Msg )
createFromDjangoMessage dm model =
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
        create model dm.text type_


createFromDjangoMessageNoDestroy : DjangoMessage -> Model -> Model
createFromDjangoMessageNoDestroy message model =
    createFromDjangoMessage message model
        |> Tuple.first


createWarning : Model -> String -> ( Model, Cmd Msg )
createWarning model text =
    create model text WarningNotification


createInfo : Model -> String -> ( Model, Cmd Msg )
createInfo model text =
    create model text InfoNotification


createSuccess : Model -> String -> ( Model, Cmd Msg )
createSuccess model text =
    create model text SuccessNotification


createNotSaved : Model -> ( Model, Cmd Msg )
createNotSaved model =
    createWarning model "Something went wrong, there :-( Your changes may not have been saved"


createLoadingFailed : String -> Model -> ( Model, Cmd Msg )
createLoadingFailed msg model =
    createWarning model msg
