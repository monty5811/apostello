module TestSerialisation exposing (suite)

import Date
import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Json.Encode as Encode
import Models.Apostello as Ap
import Test exposing (Test, fuzz, describe)


keyword : Fuzzer Ap.Keyword
keyword =
    Fuzz.map Ap.Keyword Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool


recipientSimple : Fuzzer Ap.RecipientSimple
recipientSimple =
    Fuzz.map2 Ap.RecipientSimple Fuzz.string Fuzz.int


smsInbound : Fuzzer Ap.SmsInbound
smsInbound =
    Fuzz.map Ap.SmsInbound Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe fuzzDate)
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.int)


smsOutbound : Fuzzer Ap.SmsOutbound
smsOutbound =
    Fuzz.map Ap.SmsOutbound Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap (Fuzz.maybe fuzzDate)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe recipientSimple)


userProfile : Fuzzer Ap.UserProfile
userProfile =
    Fuzz.map Ap.UserProfile Fuzz.int
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


recipient : Fuzzer Ap.Recipient
recipient =
    Fuzz.map Ap.Recipient Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap (Fuzz.maybe smsInbound)


recipientGroup : Fuzzer Ap.RecipientGroup
recipientGroup =
    Fuzz.map Ap.RecipientGroup Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.list recipientSimple)
        |> Fuzz.andMap (Fuzz.list recipientSimple)
        |> Fuzz.andMap (Fuzz.floatRange 0 10)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.bool


user : Fuzzer Ap.User
user =
    Fuzz.map4 Ap.User
        Fuzz.string
        Fuzz.string
        Fuzz.bool
        Fuzz.bool


elvantoGroup : Fuzzer Ap.ElvantoGroup
elvantoGroup =
    Fuzz.map4 Ap.ElvantoGroup
        Fuzz.string
        Fuzz.int
        Fuzz.bool
        (Fuzz.maybe fuzzDate)


queuedSms : Fuzzer Ap.QueuedSms
queuedSms =
    Fuzz.map Ap.QueuedSms Fuzz.int
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
    describe "round trip"
        [ fuzz keyword "keyword" <|
            roundTrip Ap.encodeKeyword Ap.decodeKeyword
        , fuzz smsInbound "sms inbound" <|
            roundTrip Ap.encodeSmsInbound Ap.decodeSmsInbound
        , fuzz smsOutbound "sms outbound" <|
            roundTrip Ap.encodeSmsOutbound Ap.decodeSmsOutbound
        , fuzz recipient "recipient" <|
            roundTrip Ap.encodeRecipient Ap.decodeRecipient
        , fuzz recipientGroup "recipient group" <|
            roundTrip Ap.encodeRecipientGroup Ap.decodeRecipientGroup
        , fuzz recipientSimple "recipient (simple)" <|
            roundTrip Ap.encodeRecipientSimple Ap.decodeRecipientSimple
        , fuzz user "user" <|
            roundTrip Ap.encodeUser Ap.decodeUser
        , fuzz userProfile "user profile" <|
            roundTrip Ap.encodeUserProfile Ap.decodeUserProfile
        , fuzz elvantoGroup "elvanto group" <|
            roundTrip Ap.encodeElvantoGroup Ap.decodeElvantoGroup
        , fuzz queuedSms "queued sms" <|
            roundTrip Ap.encodeQueuedSms Ap.decodeQueuedSms
        ]


roundTrip : (a -> Encode.Value) -> Decode.Decoder a -> a -> Expect.Expectation
roundTrip enc dec model =
    model
        |> enc
        |> Decode.decodeValue dec
        |> Expect.equal (Ok model)


suite : Test
suite =
    describe "serialisation" [ serialisation ]
