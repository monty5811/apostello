module Store.Decode exposing (decodeDataStore)

import Data exposing (ElvantoGroup, Keyword, QueuedSms, Recipient, RecipientGroup, RecipientSimple, SmsInbound, SmsOutbound, User, UserProfile, decodeElvantoGroup, decodeKeyword, decodeQueuedSms, decodeRecipient, decodeRecipientGroup, decodeSmsInbound, decodeSmsOutbound, decodeUser, decodeUserProfile)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import RemoteList exposing (RemoteList(NotAsked))
import Store.Model exposing (DataStore)


remoteList : List a -> Decode.Decoder (RemoteList a)
remoteList l =
    Decode.succeed (NotAsked l)


decodeDataStore : Decode.Decoder DataStore
decodeDataStore =
    decode DataStore
        |> required "inboundSms" (Decode.list decodeSmsInbound |> Decode.andThen remoteList)
        |> required "outboundSms" (Decode.list decodeSmsOutbound |> Decode.andThen remoteList)
        |> required "elvantoGroups" (Decode.list decodeElvantoGroup |> Decode.andThen remoteList)
        |> required "userprofiles" (Decode.list decodeUserProfile |> Decode.andThen remoteList)
        |> required "keywords" (Decode.list decodeKeyword |> Decode.andThen remoteList)
        |> required "recipients" (Decode.list decodeRecipient |> Decode.andThen remoteList)
        |> required "groups" (Decode.list decodeRecipientGroup |> Decode.andThen remoteList)
        |> required "queuedSms" (Decode.list decodeQueuedSms |> Decode.andThen remoteList)
        |> required "users" (Decode.list decodeUser |> Decode.andThen remoteList)
