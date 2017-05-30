module Data.Recipient exposing (Recipient, RecipientSimple, decodeRecipient, decodeRecipientSimple, encodeRecipient, encodeRecipientSimple)

import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound, encodeSmsInbound)
import Encode exposing (encodeMaybe)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias Recipient =
    { first_name : String
    , last_name : String
    , number : Maybe String
    , pk : Int
    , full_name : String
    , is_archived : Bool
    , is_blocking : Bool
    , do_not_reply : Bool
    , last_sms : Maybe SmsInbound
    }


decodeRecipient : Decode.Decoder Recipient
decodeRecipient =
    decode Recipient
        |> required "first_name" Decode.string
        |> required "last_name" Decode.string
        |> required "number" (Decode.maybe Decode.string)
        |> required "pk" Decode.int
        |> required "full_name" Decode.string
        |> required "is_archived" Decode.bool
        |> required "is_blocking" Decode.bool
        |> required "do_not_reply" Decode.bool
        |> required "last_sms" (Decode.maybe decodeSmsInbound)


encodeRecipient : Recipient -> Encode.Value
encodeRecipient contact =
    Encode.object
        [ ( "first_name", Encode.string contact.first_name )
        , ( "last_name", Encode.string contact.last_name )
        , ( "number", encodeMaybe Encode.string contact.number )
        , ( "pk", Encode.int contact.pk )
        , ( "full_name", Encode.string contact.full_name )
        , ( "is_archived", Encode.bool contact.is_archived )
        , ( "is_blocking", Encode.bool contact.is_blocking )
        , ( "do_not_reply", Encode.bool contact.do_not_reply )
        , ( "last_sms", encodeMaybe encodeSmsInbound contact.last_sms )
        ]


type alias RecipientSimple =
    { full_name : String
    , pk : Int
    }


decodeRecipientSimple : Decode.Decoder RecipientSimple
decodeRecipientSimple =
    decode RecipientSimple
        |> required "full_name" Decode.string
        |> required "pk" Decode.int


encodeRecipientSimple : RecipientSimple -> Encode.Value
encodeRecipientSimple contact =
    Encode.object
        [ ( "full_name", Encode.string contact.full_name )
        , ( "pk", Encode.int contact.pk )
        ]
