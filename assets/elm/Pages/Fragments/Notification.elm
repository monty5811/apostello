module Pages.Fragments.Notification
    exposing
        ( DjangoMessage
        , Notification
        , NotificationType
        , addListOfDjangoMessagesNoDestroy
        , createInfo
        , createLoadingFailed
        , createNotSaved
        , createSuccess
        , decodeDjangoMessage
        , refreshNotifMessage
        , remove
        , view
        )

import Dict
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Msg(RemoveNotification))
import Process
import Task
import Time


view : Notifications -> List (Html Msg)
view notifications =
    notifications
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
            "alert alert-" ++ messageType

        text =
            notification.text
                |> String.split "\n"
                |> List.map Html.text
                |> List.intersperse (Html.br [] [])
    in
    Html.div [ class className ] <|
        [ Html.i
            [ class "fa fa-close float-right"
            , onClick <| RemoveNotification id
            ]
            []
        ]
            ++ text



-- Notifications


type alias Notification =
    { type_ : NotificationType
    , text : String
    }


type alias Notifications =
    Dict.Dict Int Notification


type NotificationType
    = InfoNotification
    | SuccessNotification
    | WarningNotification
    | ErrorNotification


type alias DjangoMessage =
    { type_ : String
    , text : String
    }


decodeDjangoMessage : Decode.Decoder DjangoMessage
decodeDjangoMessage =
    decode DjangoMessage
        |> required "type_" Decode.string
        |> required "text" Decode.string



-- Update


delayAction : Time.Time -> msg -> Cmd msg
delayAction t msg =
    Process.sleep t
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


remove : Int -> Notifications -> Notifications
remove id notifications =
    Dict.remove id notifications


create : Notifications -> String -> NotificationType -> ( Notifications, Cmd Msg )
create notifications text type_ =
    let
        maxId =
            notifications
                |> Dict.keys
                |> List.maximum
                |> Maybe.withDefault 0

        newNotifications =
            Dict.insert (maxId + 1) (Notification type_ text) notifications
    in
    ( newNotifications
    , delayAction (20 * Time.second) <| RemoveNotification (maxId + 1)
    )


createFromDjangoMessage : DjangoMessage -> Notifications -> ( Notifications, Cmd Msg )
createFromDjangoMessage dm notifications =
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
    create notifications dm.text type_


createFromDjangoMessageNoDestroy : DjangoMessage -> Notifications -> Notifications
createFromDjangoMessageNoDestroy message notifications =
    createFromDjangoMessage message notifications
        |> Tuple.first


addListOfDjangoMessagesNoDestroy : List DjangoMessage -> Notifications -> Notifications
addListOfDjangoMessagesNoDestroy msgs notifications =
    List.foldl createFromDjangoMessageNoDestroy notifications msgs


refreshNotifMessage : DjangoMessage
refreshNotifMessage =
    DjangoMessage "error" "Something went wrong there, try refreshing the page and going again."


createWarning : Notifications -> String -> ( Notifications, Cmd Msg )
createWarning notifications text =
    create notifications text WarningNotification


createInfo : Notifications -> String -> ( Notifications, Cmd Msg )
createInfo notifications text =
    create notifications text InfoNotification


createSuccess : Notifications -> String -> ( Notifications, Cmd Msg )
createSuccess notifications text =
    create notifications text SuccessNotification


createNotSaved : Notifications -> ( Notifications, Cmd Msg )
createNotSaved notifications =
    createWarning notifications "Something went wrong, there :-( Your changes may not have been saved"


createLoadingFailed : String -> Notifications -> ( Notifications, Cmd Msg )
createLoadingFailed msg notifications =
    createWarning notifications msg
