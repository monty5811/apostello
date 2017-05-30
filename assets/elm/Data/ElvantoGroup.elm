module Data.ElvantoGroup exposing (ElvantoGroup, decodeElvantoGroup, encodeElvantoGroup)

import Date
import Encode exposing (encodeMaybeDate)
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias ElvantoGroup =
    { name : String
    , pk : Int
    , sync : Bool
    , last_synced : Maybe Date.Date
    }


decodeElvantoGroup : Decode.Decoder ElvantoGroup
decodeElvantoGroup =
    decode ElvantoGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "sync" Decode.bool
        |> required "last_synced" (Decode.maybe date)


encodeElvantoGroup : ElvantoGroup -> Encode.Value
encodeElvantoGroup group =
    Encode.object
        [ ( "name", Encode.string group.name )
        , ( "pk", Encode.int group.pk )
        , ( "sync", Encode.bool group.sync )
        , ( "last_synced", encodeMaybeDate group.last_synced )
        ]
