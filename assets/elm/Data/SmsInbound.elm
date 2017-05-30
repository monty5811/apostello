module Data.SmsInbound exposing (SmsInbound, decodeSmsInbound, encodeSmsInbound)

import Date
import Encode exposing (encodeMaybe, encodeMaybeDate)
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias SmsInbound =
    { sid : String
    , pk : Int
    , sender_name : String
    , content : String
    , time_received : Maybe Date.Date
    , dealt_with : Bool
    , is_archived : Bool
    , display_on_wall : Bool
    , matched_keyword : String
    , matched_colour : String
    , sender_pk : Maybe Int
    }


decodeSmsInbound : Decode.Decoder SmsInbound
decodeSmsInbound =
    decode SmsInbound
        |> required "sid" Decode.string
        |> required "pk" Decode.int
        |> required "sender_name" Decode.string
        |> required "content" Decode.string
        |> required "time_received" (Decode.maybe date)
        |> required "dealt_with" Decode.bool
        |> required "is_archived" Decode.bool
        |> required "display_on_wall" Decode.bool
        |> required "matched_keyword" Decode.string
        |> required "matched_colour" Decode.string
        |> required "sender_pk" (Decode.maybe Decode.int)


encodeSmsInbound : SmsInbound -> Encode.Value
encodeSmsInbound sms =
    Encode.object
        [ ( "sid", Encode.string sms.sid )
        , ( "pk", Encode.int sms.pk )
        , ( "sender_name", Encode.string sms.sender_name )
        , ( "content", Encode.string sms.content )
        , ( "time_received", encodeMaybeDate sms.time_received )
        , ( "dealt_with", Encode.bool sms.dealt_with )
        , ( "is_archived", Encode.bool sms.is_archived )
        , ( "display_on_wall", Encode.bool sms.display_on_wall )
        , ( "matched_keyword", Encode.string sms.matched_keyword )
        , ( "matched_colour", Encode.string sms.matched_colour )
        , ( "sender_pk", encodeMaybe Encode.int sms.sender_pk )
        ]
