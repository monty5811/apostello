module Encoders exposing (..)

import Date
import Date.Format
import Json.Encode as Encode
import Models exposing (..)


encodeDataStore : DataStore -> Encode.Value
encodeDataStore ds =
    Encode.object
        [ ( "inboundSms", (Encode.list <| List.map smsinboundEncoder ds.inboundSms) )
        , ( "outboundSms", (Encode.list <| List.map smsoutboundEncoder ds.outboundSms) )
        , ( "elvantoGroups", (Encode.list <| List.map elvantogroupEncoder ds.elvantoGroups) )
        , ( "userprofiles", (Encode.list <| List.map encodeUserProfile ds.userprofiles) )
        , ( "keywords", (Encode.list <| List.map keywordEncoder ds.keywords) )
        , ( "recipients", (Encode.list <| List.map recipientEncoder ds.recipients) )
        , ( "groups", (Encode.list <| List.map recipientgroupEncoder ds.groups) )
        , ( "queuedSms", (Encode.list <| List.map queuedsmsEncoder ds.queuedSms) )
        ]


elvantogroupEncoder : ElvantoGroup -> Encode.Value
elvantogroupEncoder group =
    Encode.object
        [ ( "name", Encode.string group.name )
        , ( "pk", Encode.int group.pk )
        , ( "sync", Encode.bool group.sync )
        , ( "last_synced", encodeMaybeDate group.last_synced )
        ]


keywordEncoder : Keyword -> Encode.Value
keywordEncoder keyword =
    Encode.object
        [ ( "keyword", Encode.string keyword.keyword )
        , ( "pk", Encode.int keyword.pk )
        , ( "description", Encode.string keyword.description )
        , ( "current_response", Encode.string keyword.current_response )
        , ( "is_live", Encode.bool keyword.is_live )
        , ( "url", Encode.string keyword.url )
        , ( "responses_url", Encode.string keyword.responses_url )
        , ( "num_replies", Encode.string keyword.num_replies )
        , ( "num_archived_replies", Encode.string keyword.num_archived_replies )
        , ( "is_archived", Encode.bool keyword.is_archived )
        ]


smsinboundEncoder : SmsInbound -> Encode.Value
smsinboundEncoder sms =
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
        , ( "matched_link", Encode.string sms.matched_link )
        , ( "sender_url", encodeMaybe Encode.string sms.sender_url )
        , ( "sender_pk", encodeMaybe Encode.int sms.sender_pk )
        ]


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder ms =
    case ms of
        Nothing ->
            Encode.null

        Just s ->
            encoder s


queuedsmsEncoder : QueuedSms -> Encode.Value
queuedsmsEncoder sms =
    Encode.object
        [ ( "pk", Encode.int sms.pk )
        , ( "time_to_send", encodeMaybeDate sms.time_to_send )
        , ( "time_to_send_formatted", Encode.string sms.time_to_send_formatted )
        , ( "sent", Encode.bool sms.sent )
        , ( "failed", Encode.bool sms.failed )
        , ( "content", Encode.string sms.content )
        , ( "recipient", recipientEncoder sms.recipient )
        , ( "recipient_group", encodeMaybe recipientgroupEncoder sms.recipient_group )
        , ( "sent_by", Encode.string sms.sent_by )
        ]


recipientgroupEncoder : RecipientGroup -> Encode.Value
recipientgroupEncoder group =
    Encode.object
        [ ( "name", Encode.string group.name )
        , ( "pk", Encode.int group.pk )
        , ( "description", Encode.string group.description )
        , ( "members", Encode.list (List.map recipientsimpleEncoder group.members) )
        , ( "nonmembers", Encode.list (List.map recipientsimpleEncoder group.nonmembers) )
        , ( "cost", Encode.float group.cost )
        , ( "url", Encode.string group.url )
        , ( "is_archived", Encode.bool group.is_archived )
        ]


recipientEncoder : Recipient -> Encode.Value
recipientEncoder contact =
    Encode.object
        [ ( "first_name", Encode.string contact.first_name )
        , ( "last_name", Encode.string contact.last_name )
        , ( "pk", Encode.int contact.pk )
        , ( "url", Encode.string contact.url )
        , ( "full_name", Encode.string contact.full_name )
        , ( "is_archived", Encode.bool contact.is_archived )
        , ( "is_blocking", Encode.bool contact.is_blocking )
        , ( "do_not_reply", Encode.bool contact.do_not_reply )
        , ( "last_sms", encodeMaybe smsinboundEncoder contact.last_sms )
        ]


recipientsimpleEncoder : RecipientSimple -> Encode.Value
recipientsimpleEncoder contact =
    Encode.object
        [ ( "full_name", Encode.string contact.full_name )
        , ( "pk", Encode.int contact.pk )
        ]


smsoutboundEncoder : SmsOutbound -> Encode.Value
smsoutboundEncoder sms =
    Encode.object
        [ ( "content", Encode.string sms.content )
        , ( "pk", Encode.int sms.pk )
        , ( "time_sent", encodeMaybeDate sms.time_sent )
        , ( "sent_by", Encode.string sms.sent_by )
        , ( "recipient", encodeMaybe recipientsimpleEncoder sms.recipient )
        ]


encodeUserProfileUser_profileUser : User -> Encode.Value
encodeUserProfileUser_profileUser record =
    Encode.object
        [ ( "email", Encode.string <| record.email )
        , ( "username", Encode.string <| record.username )
        , ( "is_staff", Encode.bool <| record.is_staff )
        , ( "is_social", Encode.bool <| record.is_social )
        ]


encodeUserProfile : UserProfile -> Encode.Value
encodeUserProfile record =
    Encode.object
        [ ( "pk", Encode.int <| record.pk )
        , ( "user", encodeUserProfileUser_profileUser <| record.user )
        , ( "approved", Encode.bool <| record.approved )
        , ( "can_see_groups", Encode.bool <| record.can_see_groups )
        , ( "can_see_contact_names", Encode.bool <| record.can_see_contact_names )
        , ( "can_see_keywords", Encode.bool <| record.can_see_keywords )
        , ( "can_see_outgoing", Encode.bool <| record.can_see_outgoing )
        , ( "can_see_incoming", Encode.bool <| record.can_see_incoming )
        , ( "can_send_sms", Encode.bool <| record.can_send_sms )
        , ( "can_see_contact_nums", Encode.bool <| record.can_see_contact_nums )
        , ( "can_import", Encode.bool <| record.can_import )
        , ( "can_archive", Encode.bool <| record.can_archive )
        ]



-- Encode Date for sending forms


encodeMaybeDate : Maybe Date.Date -> Encode.Value
encodeMaybeDate date =
    case date of
        Just d ->
            Date.Format.format "%Y-%m-%d %H:%M:%S" d
                |> Encode.string

        Nothing ->
            Encode.null
