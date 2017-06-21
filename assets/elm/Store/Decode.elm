module Store.Decode exposing (decodeDataStore)

import Data.ElvantoGroup exposing (ElvantoGroup, decodeElvantoGroup)
import Data.Keyword exposing (Keyword, decodeKeyword)
import Data.QueuedSms exposing (QueuedSms, decodeQueuedSms)
import Data.Recipient exposing (Recipient, RecipientSimple, decodeRecipient)
import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup)
import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound)
import Data.SmsOutbound exposing (SmsOutbound, decodeSmsOutbound)
import Data.User exposing (User, UserProfile, decodeUser, decodeUserProfile)
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
