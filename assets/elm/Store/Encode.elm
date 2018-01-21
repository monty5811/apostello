module Store.Encode exposing (encodeDataStore)

import Data exposing (encodeElvantoGroup, encodeKeyword, encodeQueuedSms, encodeRecipient, encodeRecipientGroup, encodeSmsInbound, encodeSmsOutbound, encodeUser, encodeUserProfile)
import Json.Encode as Encode
import RemoteList as RL
import Store.Model exposing (DataStore)


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
