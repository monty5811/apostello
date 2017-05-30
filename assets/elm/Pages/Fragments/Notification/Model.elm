module Pages.Fragments.Notification.Model exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)


type alias Notification =
    { type_ : NotificationType
    , text : String
    }


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
