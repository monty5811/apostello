module Notification
    exposing
        ( DjangoMessage
        , Msg
        , Notification
        , NotificationType(..)
        , Notifications
        , addListOfDjangoMessages
        , addRefreshNotif
        , createError
        , createInfo
        , createLoadingFailed
        , createNotSaved
        , createSuccess
        , decodeDjangoMessage
        , empty
        , remove
        , update
        , view
        )

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)


type Msg
    = Remove Notification


update : Msg -> Notifications -> Notifications
update msg notifs =
    case msg of
        Remove n ->
            remove n notifs


empty : Notifications
empty =
    []


view : Notifications -> List (Html Msg)
view notifications =
    List.map tView notifications


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
                    "danger"

        className =
            "alert alert-" ++ messageType

        text =
            notification.text
                |> String.split "\n"
                |> List.map Html.text
                |> List.intersperse (Html.br [] [])

        icon =
            if notification.showClose then
                [ Html.i
                    [ class "fa fa-close float-right"
                    , onClick <| Remove notification
                    ]
                    []
                ]
            else
                []
    in
    Html.div [ class className ] <| icon ++ text



-- Notifications


type alias Notification =
    { type_ : NotificationType
    , text : String
    , showClose : Bool
    }


type alias Notifications =
    List Notification


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


remove : Notification -> Notifications -> Notifications
remove notification notifications =
    List.filter (removeHelp notification) notifications


removeHelp : Notification -> Notification -> Bool
removeHelp notifToRemove curNotif =
    not (notifToRemove == curNotif)


create : Notifications -> String -> NotificationType -> Notifications
create notifications text type_ =
    Notification type_ text True :: notifications


createFromDjangoMessage : DjangoMessage -> Notifications -> Notifications
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


addListOfDjangoMessages : List DjangoMessage -> Notifications -> Notifications
addListOfDjangoMessages msgs notifications =
    List.foldl createFromDjangoMessage notifications msgs


refreshNotifMessage : DjangoMessage
refreshNotifMessage =
    DjangoMessage "error" "Something went wrong there, try refreshing the page and going again."


addRefreshNotif : Notifications -> Notifications
addRefreshNotif notifications =
    addListOfDjangoMessages [ refreshNotifMessage ] notifications


createError : Notifications -> String -> Notifications
createError notifications text =
    create notifications text ErrorNotification


createWarning : Notifications -> String -> Notifications
createWarning notifications text =
    create notifications text WarningNotification


createInfo : Notifications -> String -> Notifications
createInfo notifications text =
    create notifications text InfoNotification


createSuccess : Notifications -> String -> Notifications
createSuccess notifications text =
    create notifications text SuccessNotification


createNotSaved : Notifications -> Notifications
createNotSaved notifications =
    createWarning notifications "Something went wrong, there :-( Your changes may not have been saved"


createLoadingFailed : String -> Notifications -> Notifications
createLoadingFailed msg notifications =
    createWarning notifications msg
