module TestSerialisation exposing (serialisation)

import Data.ElvantoGroup exposing (ElvantoGroup, decodeElvantoGroup, encodeElvantoGroup)
import Data.Keyword exposing (Keyword, decodeKeyword, encodeKeyword)
import Data.QueuedSms exposing (QueuedSms, decodeQueuedSms, encodeQueuedSms)
import Data.Recipient exposing (Recipient, RecipientSimple, decodeRecipient, decodeRecipientSimple, encodeRecipient, encodeRecipientSimple)
import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup, encodeRecipientGroup)
import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound, encodeSmsInbound)
import Data.SmsOutbound exposing (SmsOutbound, decodeSmsOutbound, encodeSmsOutbound)
import Data.User exposing (User, UserProfile, decodeUser, decodeUserProfile, encodeUser, encodeUserProfile)
import Date
import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (Test, describe, fuzz)


keyword : Fuzzer Keyword
keyword =
    Fuzz.map Keyword Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap fuzzDate
        |> Fuzz.andMap (Fuzz.maybe fuzzDate)
        |> Fuzz.andMap (Fuzz.list Fuzz.int)
        |> Fuzz.andMap (Fuzz.list Fuzz.int)
        |> Fuzz.andMap (Fuzz.list Fuzz.int)


recipientSimple : Fuzzer RecipientSimple
recipientSimple =
    Fuzz.map2 RecipientSimple Fuzz.string Fuzz.int


smsInbound : Fuzzer SmsInbound
smsInbound =
    Fuzz.map SmsInbound Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe fuzzDate)
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.int)


smsOutbound : Fuzzer SmsOutbound
smsOutbound =
    Fuzz.map SmsOutbound Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap (Fuzz.maybe fuzzDate)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe recipientSimple)


userProfile : Fuzzer UserProfile
userProfile =
    Fuzz.map UserProfile Fuzz.int
        |> Fuzz.andMap user
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool


recipient : Fuzzer Recipient
recipient =
    Fuzz.map Recipient Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap (Fuzz.maybe smsInbound)


recipientGroup : Fuzzer RecipientGroup
recipientGroup =
    Fuzz.map RecipientGroup Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.list recipientSimple)
        |> Fuzz.andMap (Fuzz.list recipientSimple)
        |> Fuzz.andMap (Fuzz.floatRange 0 10)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool


user : Fuzzer User
user =
    Fuzz.map5 User
        Fuzz.int
        Fuzz.string
        Fuzz.string
        Fuzz.bool
        Fuzz.bool


elvantoGroup : Fuzzer ElvantoGroup
elvantoGroup =
    Fuzz.map4 ElvantoGroup
        Fuzz.string
        Fuzz.int
        Fuzz.bool
        (Fuzz.maybe fuzzDate)


queuedSms : Fuzzer QueuedSms
queuedSms =
    Fuzz.map QueuedSms Fuzz.int
        |> Fuzz.andMap (Fuzz.maybe fuzzDate)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap recipient
        |> Fuzz.andMap (Fuzz.maybe recipientGroup)
        |> Fuzz.andMap Fuzz.string


fuzzDate : Fuzzer Date.Date
fuzzDate =
    Fuzz.map float2DateNoMillisec <| Fuzz.floatRange 1300000000 3000000000


float2DateNoMillisec : Float -> Date.Date
float2DateNoMillisec f =
    -- hack to have zero milliseconds as the encoder/decoder ignores milliseconds
    f
        |> (/) 1000
        |> floor
        |> (*) 1000
        |> toFloat
        |> Date.fromTime


serialisation : Test
serialisation =
    describe "serialisation round trip"
        [ fuzz keyword "keyword" <|
            roundTrip encodeKeyword decodeKeyword
        , fuzz smsInbound "sms inbound" <|
            roundTrip encodeSmsInbound decodeSmsInbound
        , fuzz smsOutbound "sms outbound" <|
            roundTrip encodeSmsOutbound decodeSmsOutbound
        , fuzz recipient "recipient" <|
            roundTrip encodeRecipient decodeRecipient
        , fuzz recipientGroup "recipient group" <|
            roundTrip encodeRecipientGroup decodeRecipientGroup
        , fuzz recipientSimple "recipient (simple)" <|
            roundTrip encodeRecipientSimple decodeRecipientSimple
        , fuzz user "user" <|
            roundTrip encodeUser decodeUser
        , fuzz userProfile "user profile" <|
            roundTrip encodeUserProfile decodeUserProfile
        , fuzz elvantoGroup "elvanto group" <|
            roundTrip encodeElvantoGroup decodeElvantoGroup
        , fuzz queuedSms "queued sms" <|
            roundTrip encodeQueuedSms decodeQueuedSms
        ]


roundTrip : (a -> Encode.Value) -> Decode.Decoder a -> a -> Expect.Expectation
roundTrip enc dec model =
    model
        |> enc
        |> Decode.decodeValue dec
        |> Expect.equal (Ok model)
