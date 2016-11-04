module Decoders exposing (..)

import Json.Decode as Decode exposing ((:=), maybe)
import Json.Decode.Pipeline exposing (optional, required, decode)
import Json.Encode as Encode
import ApostelloModels exposing (..)


groupDecoder : Decode.Decoder Group
groupDecoder =
    decode Group
        |> required "pk" Decode.int
        |> required "name" Decode.string
        |> required "members" (Decode.list personDecoder)


personDecoder : Decode.Decoder Person
personDecoder =
    decode Person
        |> required "full_name" Decode.string
        |> required "pk" Decode.int


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True
