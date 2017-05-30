module Data.QueuedSms exposing (QueuedSms, decodeQueuedSms, encodeQueuedSms)

import Data.Recipient exposing (Recipient, decodeRecipient, encodeRecipient)
import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup, encodeRecipientGroup)
import Date
import Encode exposing (encodeMaybe, encodeMaybeDate)
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias QueuedSms =
    { pk : Int
    , time_to_send : Maybe Date.Date
    , time_to_send_formatted : String
    , sent : Bool
    , failed : Bool
    , content : String
    , recipient : Recipient
    , recipient_group : Maybe RecipientGroup
    , sent_by : String
    }


decodeQueuedSms : Decode.Decoder QueuedSms
decodeQueuedSms =
    decode QueuedSms
        |> required "pk" Decode.int
        |> required "time_to_send" (Decode.maybe date)
        |> required "time_to_send_formatted" Decode.string
        |> required "sent" Decode.bool
        |> required "failed" Decode.bool
        |> required "content" Decode.string
        |> required "recipient" decodeRecipient
        |> required "recipient_group" (Decode.maybe decodeRecipientGroup)
        |> required "sent_by" Decode.string


encodeQueuedSms : QueuedSms -> Encode.Value
encodeQueuedSms sms =
    Encode.object
        [ ( "pk", Encode.int sms.pk )
        , ( "time_to_send", encodeMaybeDate sms.time_to_send )
        , ( "time_to_send_formatted", Encode.string sms.time_to_send_formatted )
        , ( "sent", Encode.bool sms.sent )
        , ( "failed", Encode.bool sms.failed )
        , ( "content", Encode.string sms.content )
        , ( "recipient", encodeRecipient sms.recipient )
        , ( "recipient_group", encodeMaybe encodeRecipientGroup sms.recipient_group )
        , ( "sent_by", Encode.string sms.sent_by )
        ]
