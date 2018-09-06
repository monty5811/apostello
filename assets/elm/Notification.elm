module Notification exposing
    ( DjangoMessage
    , Msg
    , Notification
    , NotificationType(..)
    , Notifications
    , addError
    , addInfo
    , addListOfDjangoMessages
    , addLoadingFailed
    , addNotSaved
    , addNs
    , addRefreshNotif
    , addSuccess
    , createListOfDjangoMessages
    , decodeDjangoMessage
    , empty
    , refreshNotifMessage
    , remove
    , update
    , updateNotifications
    , view
    )

import Css
import Html exposing (Html)
import Html.Attributes as A
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


updateNotifications : Notifications -> { a | notifications : Notifications } -> { a | notifications : Notifications }
updateNotifications new a =
    { a | notifications = addNs new a.notifications }


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

        text =
            notification.text
                |> String.split "\n"
                |> List.map Html.text
                |> List.intersperse (Html.br [] [])

        icon =
            if notification.showClose then
                [ Html.i
                    [ A.class "fa fa-close"
                    , onClick <| Remove notification
                    , Css.float_right
                    ]
                    []
                ]

            else
                []
    in
    Html.div
        [ Css.mb_2
        , A.class <| "alert alert-" ++ messageType
        , A.attribute "role" "alert"
        ]
    <|
        icon
            ++ text



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


createListOfDjangoMessages : List DjangoMessage -> Notifications
createListOfDjangoMessages dms =
    List.map createFromDjangoMessage dms


createFromDjangoMessage : DjangoMessage -> Notification
createFromDjangoMessage dm =
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
    Notification type_ dm.text True


add : Notifications -> String -> NotificationType -> Notifications
add notifications text type_ =
    Notification type_ text True :: notifications


addN : Notification -> Notifications -> Notifications
addN n notifications =
    n :: notifications


addNs : Notifications -> Notifications -> Notifications
addNs new notifications =
    new ++ notifications


addDjangoMessage : DjangoMessage -> Notifications -> Notifications
addDjangoMessage dm notifications =
    addN (createFromDjangoMessage dm) notifications


addListOfDjangoMessages : List DjangoMessage -> Notifications -> Notifications
addListOfDjangoMessages msgs notifications =
    List.foldl addDjangoMessage notifications msgs


refreshNotifMessage : Notification
refreshNotifMessage =
    createFromDjangoMessage <|
        DjangoMessage "error" "Something went wrong there, try refreshing the page and going again."


addRefreshNotif : Notifications -> Notifications
addRefreshNotif notifications =
    addN refreshNotifMessage notifications


addError : Notifications -> String -> Notifications
addError notifications text =
    add notifications text ErrorNotification


addWarning : Notifications -> String -> Notifications
addWarning notifications text =
    add notifications text WarningNotification


addInfo : Notifications -> String -> Notifications
addInfo notifications text =
    add notifications text InfoNotification


addSuccess : Notifications -> String -> Notifications
addSuccess notifications text =
    add notifications text SuccessNotification


addNotSaved : Notifications -> Notifications
addNotSaved notifications =
    addWarning notifications "Something went wrong, there :-( Your changes may not have been saved"


addLoadingFailed : String -> Notifications -> Notifications
addLoadingFailed msg notifications =
    addWarning notifications msg
