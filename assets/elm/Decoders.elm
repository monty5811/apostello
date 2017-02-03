module Decoders exposing (..)

import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (optional, required, decode, requiredAt)
import Models exposing (..)


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True


dataFromResp : Decode.Decoder a -> RawResponse -> List a
dataFromResp decoder rawResp =
    rawResp.body
        |> Decode.decodeString (Decode.field "results" (Decode.list decoder))
        |> Result.withDefault []


itemFromResp : a -> Decode.Decoder a -> RawResponse -> a
itemFromResp defaultCallback decoder rawResp =
    rawResp.body
        |> Decode.decodeString decoder
        |> Result.withDefault defaultCallback


decodeFirstRunResp : Decode.Decoder FirstRunResp
decodeFirstRunResp =
    decode FirstRunResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


elvantogroupDecoder : Decode.Decoder ElvantoGroup
elvantogroupDecoder =
    decode ElvantoGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "sync" Decode.bool
        |> required "last_synced" (Decode.maybe date)


keywordDecoder : Decode.Decoder Keyword
keywordDecoder =
    decode Keyword
        |> required "keyword" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> required "current_response" Decode.string
        |> required "is_live" Decode.bool
        |> required "url" Decode.string
        |> required "responses_url" Decode.string
        |> required "num_replies" Decode.string
        |> required "num_archived_replies" Decode.string
        |> required "is_archived" Decode.bool


queuedsmsDecoder : Decode.Decoder QueuedSms
queuedsmsDecoder =
    decode QueuedSms
        |> required "pk" Decode.int
        |> required "time_to_send" (Decode.maybe date)
        |> required "time_to_send_formatted" Decode.string
        |> required "sent" Decode.bool
        |> required "failed" Decode.bool
        |> required "content" Decode.string
        |> required "recipient" recipientDecoder
        |> required "recipient_group" (Decode.maybe recipientgroupDecoder)
        |> required "sent_by" Decode.string


recipientgroupDecoder : Decode.Decoder RecipientGroup
recipientgroupDecoder =
    decode RecipientGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> optional "members" (Decode.list recipientsimpleDecoder) []
        |> optional "nonmembers" (Decode.list recipientsimpleDecoder) []
        |> required "cost" Decode.string
        |> required "url" Decode.string
        |> required "is_archived" Decode.bool


recipientDecoder : Decode.Decoder Recipient
recipientDecoder =
    decode Recipient
        |> required "first_name" Decode.string
        |> required "last_name" Decode.string
        |> required "pk" Decode.int
        |> required "url" Decode.string
        |> required "full_name" Decode.string
        |> required "number" Decode.string
        |> required "is_archived" Decode.bool
        |> required "is_blocking" Decode.bool
        |> required "do_not_reply" Decode.bool
        |> required "last_sms" (Decode.maybe smsinboundsimpleDecoder)


recipientsimpleDecoder : Decode.Decoder RecipientSimple
recipientsimpleDecoder =
    decode RecipientSimple
        |> required "full_name" Decode.string
        |> required "pk" Decode.int


smsinboundDecoder : Decode.Decoder SmsInbound
smsinboundDecoder =
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
        |> required "matched_link" Decode.string
        |> required "sender_url" (Decode.maybe Decode.string)
        |> required "sender_pk" (Decode.maybe Decode.int)


smsinboundsimpleDecoder : Decode.Decoder SmsInboundSimple
smsinboundsimpleDecoder =
    decode SmsInboundSimple
        |> required "pk" Decode.int
        |> required "content" Decode.string
        |> required "time_received" (Decode.maybe date)
        |> required "is_archived" Decode.bool
        |> required "display_on_wall" Decode.bool
        |> required "matched_keyword" Decode.string


smsoutboundDecoder : Decode.Decoder SmsOutbound
smsoutboundDecoder =
    decode SmsOutbound
        |> required "content" Decode.string
        |> required "pk" Decode.int
        |> required "time_sent" (Decode.maybe date)
        |> required "sent_by" Decode.string
        |> required "recipient" (Decode.maybe recipientsimpleDecoder)


userprofileDecoder : Decode.Decoder UserProfile
userprofileDecoder =
    decode UserProfile
        |> required "pk" Decode.int
        |> required "user" userDecoder
        |> required "url" Decode.string
        |> required "approved" Decode.bool
        |> required "can_see_groups" Decode.bool
        |> required "can_see_contact_names" Decode.bool
        |> required "can_see_keywords" Decode.bool
        |> required "can_see_outgoing" Decode.bool
        |> required "can_see_incoming" Decode.bool
        |> required "can_send_sms" Decode.bool
        |> required "can_see_contact_nums" Decode.bool
        |> required "can_import" Decode.bool
        |> required "can_archive" Decode.bool


userDecoder : Decode.Decoder User
userDecoder =
    decode User
        |> required "email" Decode.string
        |> required "username" Decode.string
