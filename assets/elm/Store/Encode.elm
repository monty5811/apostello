module Store.Encode exposing (encodeDataStore)

import Data.ElvantoGroup exposing (ElvantoGroup, encodeElvantoGroup)
import Data.Keyword exposing (Keyword, encodeKeyword)
import Data.QueuedSms exposing (QueuedSms, encodeQueuedSms)
import Data.Recipient exposing (Recipient, RecipientSimple, encodeRecipient)
import Data.RecipientGroup exposing (RecipientGroup, encodeRecipientGroup)
import Data.SmsInbound exposing (SmsInbound, encodeSmsInbound)
import Data.SmsOutbound exposing (SmsOutbound, encodeSmsOutbound)
import Data.User exposing (User, UserProfile, encodeUser, encodeUserProfile)
import Json.Encode as Encode
import Store.Model exposing (DataStore)
import RemoteList as RL


encodeDataStore : DataStore -> Encode.Value
encodeDataStore ds =
    Encode.object
        [ ( "inboundSms", Encode.list <| List.map encodeSmsInbound <| RL.toList ds.inboundSms )
        , ( "outboundSms", Encode.list <| List.map encodeSmsOutbound <| RL.toList ds.outboundSms )
        , ( "elvantoGroups", Encode.list <| List.map encodeElvantoGroup <| RL.toList ds.elvantoGroups )
        , ( "userprofiles", Encode.list <| List.map encodeUserProfile <| RL.toList ds.userprofiles )
        , ( "keywords", Encode.list <| List.map encodeKeyword <| RL.toList ds.keywords )
        , ( "recipients", Encode.list <| List.map encodeRecipient <| RL.toList ds.recipients )
        , ( "groups", Encode.list <| List.map encodeRecipientGroup <| RL.toList ds.groups )
        , ( "queuedSms", Encode.list <| List.map encodeQueuedSms <| RL.toList ds.queuedSms )
        , ( "users", Encode.list <| List.map encodeUser <| RL.toList ds.users )
        ]
