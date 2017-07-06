module Data.RecipientGroup exposing (GroupPk, RecipientGroup, decodeRecipientGroup, encodeRecipientGroup, nullGroup)

import Data.Recipient exposing (RecipientSimple, decodeRecipientSimple, encodeRecipientSimple)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode


type alias RecipientGroup =
    { name : String
    , pk : Int
    , description : String
    , members : List RecipientSimple
    , nonmembers : List RecipientSimple
    , cost : Float
    , is_archived : Bool
    }


type alias GroupPk =
    Int


nullGroup : RecipientGroup
nullGroup =
    RecipientGroup "" 0 "" [] [] 0 False


decodeRecipientGroup : Decode.Decoder RecipientGroup
decodeRecipientGroup =
    decode RecipientGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> optional "members" (Decode.list decodeRecipientSimple) []
        |> optional "nonmembers" (Decode.list decodeRecipientSimple) []
        |> required "cost" Decode.float
        |> required "is_archived" Decode.bool


encodeRecipientGroup : RecipientGroup -> Encode.Value
encodeRecipientGroup group =
    Encode.object
        [ ( "name", Encode.string group.name )
        , ( "pk", Encode.int group.pk )
        , ( "description", Encode.string group.description )
        , ( "members", Encode.list (List.map encodeRecipientSimple group.members) )
        , ( "nonmembers", Encode.list (List.map encodeRecipientSimple group.nonmembers) )
        , ( "cost", Encode.float group.cost )
        , ( "is_archived", Encode.bool group.is_archived )
        ]
