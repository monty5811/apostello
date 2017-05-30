module Data.SmsOutbound exposing (SmsOutbound, decodeSmsOutbound, encodeSmsOutbound)

import Data.Recipient exposing (RecipientSimple, decodeRecipientSimple, encodeRecipientSimple)
import Date
import Encode exposing (encodeMaybe, encodeMaybeDate)
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias SmsOutbound =
    { content : String
    , pk : Int
    , time_sent : Maybe Date.Date
    , sent_by : String
    , recipient : Maybe RecipientSimple
    }


decodeSmsOutbound : Decode.Decoder SmsOutbound
decodeSmsOutbound =
    decode SmsOutbound
        |> required "content" Decode.string
        |> required "pk" Decode.int
        |> required "time_sent" (Decode.maybe date)
        |> required "sent_by" Decode.string
        |> required "recipient" (Decode.maybe decodeRecipientSimple)


encodeSmsOutbound : SmsOutbound -> Encode.Value
encodeSmsOutbound sms =
    Encode.object
        [ ( "content", Encode.string sms.content )
        , ( "pk", Encode.int sms.pk )
        , ( "time_sent", encodeMaybeDate sms.time_sent )
        , ( "sent_by", Encode.string sms.sent_by )
        , ( "recipient", encodeMaybe encodeRecipientSimple sms.recipient )
        ]
