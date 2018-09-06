module Data exposing (ElvantoGroup, GroupPk, Keyword, MessageDeliveryStatus(..), QueuedSms, Recipient, RecipientGroup, RecipientSimple, SmsInbound, SmsOutbound, User, UserProfile, decodeElvantoGroup, decodeKeyword, decodeQueuedSms, decodeRecipient, decodeRecipientGroup, decodeRecipientSimple, decodeSmsInbound, decodeSmsOutbound, decodeStatus, decodeUser, decodeUserProfile, encodeElvantoGroup, encodeKeyword, encodeQueuedSms, encodeRecipient, encodeRecipientGroup, encodeRecipientSimple, encodeSmsInbound, encodeSmsOutbound, encodeUser, encodeUserProfile, mdStatusFromString, nullGroup, stringFromMDStatus)

import Date
import Encode exposing (encodeDate, encodeMaybe, encodeMaybeDate)
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (custom, decode, optional, required)
import Json.Encode as Encode



-- Inbound SMS


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



-- Outbound SMS


type alias SmsOutbound =
    { content : String
    , pk : Int
    , time_sent : Maybe Date.Date
    , sent_by : String
    , recipient : Maybe RecipientSimple
    , status : MessageDeliveryStatus
    }


decodeSmsOutbound : Decode.Decoder SmsOutbound
decodeSmsOutbound =
    decode SmsOutbound
        |> required "content" Decode.string
        |> required "pk" Decode.int
        |> required "time_sent" (Decode.maybe date)
        |> required "sent_by" Decode.string
        |> required "recipient" (Decode.maybe decodeRecipientSimple)
        |> custom (Decode.at [ "status" ] (Decode.andThen decodeStatus Decode.string))


encodeSmsOutbound : SmsOutbound -> Encode.Value
encodeSmsOutbound sms =
    Encode.object
        [ ( "content", Encode.string sms.content )
        , ( "pk", Encode.int sms.pk )
        , ( "time_sent", encodeMaybeDate sms.time_sent )
        , ( "sent_by", Encode.string sms.sent_by )
        , ( "recipient", encodeMaybe encodeRecipientSimple sms.recipient )
        , ( "status", Encode.string (String.toLower <| stringFromMDStatus sms.status) )
        ]



-- Status


decodeStatus : String -> Decode.Decoder MessageDeliveryStatus
decodeStatus status =
    Decode.succeed (mdStatusFromString status)


type MessageDeliveryStatus
    = Accepted
    | Queued
    | Sending
    | Sent
    | Receiving
    | Received
    | Delivered
    | Undelivered
    | Failed
    | Unknown


mdStatusFromString : String -> MessageDeliveryStatus
mdStatusFromString str =
    case str of
        "accepted" ->
            Accepted

        "queued" ->
            Queued

        "sending" ->
            Sending

        "sent" ->
            Sent

        "receiving" ->
            Receiving

        "received" ->
            Received

        "delivered" ->
            Delivered

        "undelivered" ->
            Undelivered

        "failed" ->
            Failed

        _ ->
            Unknown


stringFromMDStatus : MessageDeliveryStatus -> String
stringFromMDStatus status =
    case status of
        Accepted ->
            "Accepted"

        Queued ->
            "Queued"

        Sending ->
            "Sending"

        Sent ->
            "Sent"

        Receiving ->
            "Receiving"

        Received ->
            "Received"

        Delivered ->
            "Delivered"

        Undelivered ->
            "Undelivered"

        Failed ->
            "Failed"

        Unknown ->
            "Unknown"



-- Recipient


type alias Recipient =
    { first_name : String
    , last_name : String
    , number : Maybe String
    , pk : Int
    , full_name : String
    , is_archived : Bool
    , is_blocking : Bool
    , do_not_reply : Bool
    , never_contact : Bool
    , notes : String
    , last_sms : Maybe SmsInbound
    }


decodeRecipient : Decode.Decoder Recipient
decodeRecipient =
    decode Recipient
        |> required "first_name" Decode.string
        |> required "last_name" Decode.string
        |> required "number" (Decode.maybe Decode.string)
        |> required "pk" Decode.int
        |> required "full_name" Decode.string
        |> required "is_archived" Decode.bool
        |> required "is_blocking" Decode.bool
        |> required "do_not_reply" Decode.bool
        |> required "never_contact" Decode.bool
        |> optional "notes" Decode.string ""
        |> required "last_sms" (Decode.maybe decodeSmsInbound)


encodeRecipient : Recipient -> Encode.Value
encodeRecipient contact =
    Encode.object
        [ ( "first_name", Encode.string contact.first_name )
        , ( "last_name", Encode.string contact.last_name )
        , ( "number", encodeMaybe Encode.string contact.number )
        , ( "pk", Encode.int contact.pk )
        , ( "full_name", Encode.string contact.full_name )
        , ( "is_archived", Encode.bool contact.is_archived )
        , ( "is_blocking", Encode.bool contact.is_blocking )
        , ( "do_not_reply", Encode.bool contact.do_not_reply )
        , ( "never_contact", Encode.bool contact.never_contact )
        , ( "notes", Encode.string contact.notes )
        , ( "last_sms", encodeMaybe encodeSmsInbound contact.last_sms )
        ]


type alias RecipientSimple =
    { full_name : String
    , pk : Int
    }


decodeRecipientSimple : Decode.Decoder RecipientSimple
decodeRecipientSimple =
    decode RecipientSimple
        |> required "full_name" Decode.string
        |> required "pk" Decode.int


encodeRecipientSimple : RecipientSimple -> Encode.Value
encodeRecipientSimple contact =
    Encode.object
        [ ( "full_name", Encode.string contact.full_name )
        , ( "pk", Encode.int contact.pk )
        ]



-- Recipient Group


type alias RecipientGroup =
    { name : String
    , pk : Int
    , description : String
    , members : List RecipientSimple
    , nonmembers : List RecipientSimple
    , cost : Float
    , is_archived : Bool
    }


type alias GroupPk =
    Int


nullGroup : RecipientGroup
nullGroup =
    RecipientGroup "" 0 "" [] [] 0 False


decodeRecipientGroup : Decode.Decoder RecipientGroup
decodeRecipientGroup =
    decode RecipientGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> optional "members" (Decode.list decodeRecipientSimple) []
        |> optional "nonmembers" (Decode.list decodeRecipientSimple) []
        |> required "cost" Decode.float
        |> required "is_archived" Decode.bool


encodeRecipientGroup : RecipientGroup -> Encode.Value
encodeRecipientGroup group =
    Encode.object
        [ ( "name", Encode.string group.name )
        , ( "pk", Encode.int group.pk )
        , ( "description", Encode.string group.description )
        , ( "members", Encode.list (List.map encodeRecipientSimple group.members) )
        , ( "nonmembers", Encode.list (List.map encodeRecipientSimple group.nonmembers) )
        , ( "cost", Encode.float group.cost )
        , ( "is_archived", Encode.bool group.is_archived )
        ]



-- Keywords


type alias Keyword =
    { keyword : String
    , pk : Int
    , description : String
    , current_response : String
    , is_live : Bool
    , num_replies : String
    , num_archived_replies : String
    , is_archived : Bool
    , disable_all_replies : Bool
    , custom_response : String
    , custom_response_new_person : String
    , deactivated_response : String
    , too_early_response : String
    , activate_time : Date.Date
    , deactivate_time : Maybe Date.Date
    , linked_groups : List Int
    , owners : List Int
    , subscribed_to_digest : List Int
    }


decodeKeyword : Decode.Decoder Keyword
decodeKeyword =
    decode Keyword
        |> required "keyword" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> required "current_response" Decode.string
        |> required "is_live" Decode.bool
        |> required "num_replies" Decode.string
        |> required "num_archived_replies" Decode.string
        |> required "is_archived" Decode.bool
        |> required "disable_all_replies" Decode.bool
        |> required "custom_response" Decode.string
        |> required "custom_response_new_person" Decode.string
        |> required "deactivated_response" Decode.string
        |> required "too_early_response" Decode.string
        |> required "activate_time" date
        |> required "deactivate_time" (Decode.maybe date)
        |> required "linked_groups" (Decode.list Decode.int)
        |> required "owners" (Decode.list Decode.int)
        |> required "subscribed_to_digest" (Decode.list Decode.int)


encodeKeyword : Keyword -> Encode.Value
encodeKeyword keyword =
    Encode.object
        [ ( "keyword", Encode.string keyword.keyword )
        , ( "pk", Encode.int keyword.pk )
        , ( "description", Encode.string keyword.description )
        , ( "current_response", Encode.string keyword.current_response )
        , ( "is_live", Encode.bool keyword.is_live )
        , ( "num_replies", Encode.string keyword.num_replies )
        , ( "num_archived_replies", Encode.string keyword.num_archived_replies )
        , ( "is_archived", Encode.bool keyword.is_archived )
        , ( "disable_all_replies", Encode.bool keyword.disable_all_replies )
        , ( "custom_response", Encode.string keyword.custom_response )
        , ( "custom_response_new_person", Encode.string keyword.custom_response_new_person )
        , ( "deactivated_response", Encode.string keyword.deactivated_response )
        , ( "too_early_response", Encode.string keyword.too_early_response )
        , ( "activate_time", encodeDate keyword.activate_time )
        , ( "deactivate_time", encodeMaybeDate keyword.deactivate_time )
        , ( "linked_groups", Encode.list (List.map Encode.int keyword.linked_groups) )
        , ( "owners", Encode.list (List.map Encode.int keyword.owners) )
        , ( "subscribed_to_digest", Encode.list (List.map Encode.int keyword.subscribed_to_digest) )
        ]



-- Queued SMS


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



-- Elvanto


type alias ElvantoGroup =
    { name : String
    , pk : Int
    , sync : Bool
    , last_synced : Maybe Date.Date
    }


decodeElvantoGroup : Decode.Decoder ElvantoGroup
decodeElvantoGroup =
    decode ElvantoGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "sync" Decode.bool
        |> required "last_synced" (Decode.maybe date)


encodeElvantoGroup : ElvantoGroup -> Encode.Value
encodeElvantoGroup group =
    Encode.object
        [ ( "name", Encode.string group.name )
        , ( "pk", Encode.int group.pk )
        , ( "sync", Encode.bool group.sync )
        , ( "last_synced", encodeMaybeDate group.last_synced )
        ]



-- Users


type alias UserProfile =
    { pk : Int
    , user : User
    , approved : Bool
    , message_cost_limit : Float
    , can_see_groups : Bool
    , can_see_contact_names : Bool
    , can_see_keywords : Bool
    , can_see_outgoing : Bool
    , can_see_incoming : Bool
    , can_send_sms : Bool
    , can_see_contact_nums : Bool
    , can_see_contact_notes : Bool
    , can_import : Bool
    , can_archive : Bool
    }


decodeUserProfile : Decode.Decoder UserProfile
decodeUserProfile =
    decode UserProfile
        |> required "pk" Decode.int
        |> required "user" decodeUser
        |> required "approved" Decode.bool
        |> required "message_cost_limit" Decode.float
        |> required "can_see_groups" Decode.bool
        |> required "can_see_contact_names" Decode.bool
        |> required "can_see_keywords" Decode.bool
        |> required "can_see_outgoing" Decode.bool
        |> required "can_see_incoming" Decode.bool
        |> required "can_send_sms" Decode.bool
        |> required "can_see_contact_nums" Decode.bool
        |> required "can_see_contact_notes" Decode.bool
        |> required "can_import" Decode.bool
        |> required "can_archive" Decode.bool


encodeUserProfile : UserProfile -> Encode.Value
encodeUserProfile record =
    Encode.object
        [ ( "pk", Encode.int record.pk )
        , ( "user", encodeUser record.user )
        , ( "approved", Encode.bool record.approved )
        , ( "message_cost_limit", Encode.float record.message_cost_limit )
        , ( "can_see_groups", Encode.bool record.can_see_groups )
        , ( "can_see_contact_names", Encode.bool record.can_see_contact_names )
        , ( "can_see_keywords", Encode.bool record.can_see_keywords )
        , ( "can_see_outgoing", Encode.bool record.can_see_outgoing )
        , ( "can_see_incoming", Encode.bool record.can_see_incoming )
        , ( "can_send_sms", Encode.bool record.can_send_sms )
        , ( "can_see_contact_nums", Encode.bool record.can_see_contact_nums )
        , ( "can_see_contact_notes", Encode.bool record.can_see_contact_notes )
        , ( "can_import", Encode.bool record.can_import )
        , ( "can_archive", Encode.bool record.can_archive )
        ]


type alias User =
    { pk : Int
    , email : String
    , username : String
    , is_staff : Bool
    , is_social : Bool
    }


decodeUser : Decode.Decoder User
decodeUser =
    decode User
        |> required "pk" Decode.int
        |> required "email" Decode.string
        |> required "username" Decode.string
        |> required "is_staff" Decode.bool
        |> required "is_social" Decode.bool


encodeUser : User -> Encode.Value
encodeUser user =
    Encode.object
        [ ( "pk", Encode.int user.pk )
        , ( "email", Encode.string user.email )
        , ( "username", Encode.string user.username )
        , ( "is_staff", Encode.bool user.is_staff )
        , ( "is_social", Encode.bool user.is_social )
        ]
