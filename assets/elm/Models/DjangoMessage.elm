module Models.DjangoMessage exposing (DjangoMessage, decodeDjangoMessage)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, decode)


type alias DjangoMessage =
    { type_ : String
    , text : String
    }


decodeDjangoMessage : Decode.Decoder DjangoMessage
decodeDjangoMessage =
    decode DjangoMessage
        |> required "type_" Decode.string
        |> required "text" Decode.string
