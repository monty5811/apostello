module Store.Toggle exposing (..)

import Data.ElvantoGroup exposing (ElvantoGroup, decodeElvantoGroup)
import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup)
import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound)
import Data.User exposing (UserProfile, decodeUserProfile, encodeUserProfile)
import DjangoSend exposing (CSRFToken, archivePost, archivePostRaw, post, rawPost)
import Http
import Json.Encode as Encode
import Messages exposing (Msg(StoreMsg))
import Store.Messages exposing (StoreMsg(..))
import Urls


smsDealtWith : CSRFToken -> Bool -> Int -> Cmd Msg
smsDealtWith csrf isDealtWith pk =
    let
        body =
            [ ( "dealt_with", Encode.bool isDealtWith ) ]
    in
    post csrf (Urls.api_toggle_deal_with_sms pk) body decodeSmsInbound
        |> Http.send (StoreMsg << ReceiveToggleInboundSmsDealtWith)


smsArchive : CSRFToken -> Bool -> Int -> Cmd Msg
smsArchive csrf isArchived pk =
    archivePost csrf (Urls.api_act_archive_sms pk) isArchived decodeSmsInbound
        |> Http.send (StoreMsg << ReceiveToggleInboundSmsArchive)


reprocessSms : CSRFToken -> Int -> Cmd Msg
reprocessSms csrf pk =
    let
        body =
            [ ( "reingest", Encode.bool True ) ]
    in
    post csrf (Urls.api_act_reingest_sms pk) body decodeSmsInbound
        |> Http.send (StoreMsg << ReceiveReprocessSms)


profileField : CSRFToken -> UserProfile -> Cmd Msg
profileField csrf profile =
    let
        url =
            Urls.api_user_profile_update profile.pk

        body =
            [ ( "user_profile", encodeUserProfile <| profile ) ]
    in
    post csrf url body decodeUserProfile
        |> Http.send (StoreMsg << ReceiveToggleProfileField)


recipientArchive : CSRFToken -> Bool -> Int -> Cmd Msg
recipientArchive csrf isArchived pk =
    archivePostRaw csrf (Urls.api_act_archive_recipient pk) isArchived
        |> Http.send (StoreMsg << ReceiveLazy)


recipientGroupArchive : CSRFToken -> Bool -> Int -> Cmd Msg
recipientGroupArchive csrf isArchived pk =
    archivePostRaw csrf (Urls.api_act_archive_group pk) isArchived
        |> Http.send (StoreMsg << ReceiveLazy)


archiveKeyword : CSRFToken -> Bool -> String -> Cmd Msg
archiveKeyword csrf isArchived k =
    archivePostRaw csrf (Urls.api_act_archive_keyword k) isArchived
        |> Http.send (StoreMsg << ReceiveLazy)


wallDisplay : CSRFToken -> Bool -> Int -> Cmd Msg
wallDisplay csrf isDisplayed pk =
    let
        url =
            Urls.api_toggle_display_on_wall pk

        body =
            [ ( "display_on_wall", Encode.bool isDisplayed ) ]
    in
    post csrf url body decodeSmsInbound
        |> Http.send (StoreMsg << ReceiveToggleWallDisplay)


cancelSms : CSRFToken -> Int -> Cmd Msg
cancelSms csrf pk =
    let
        url =
            Urls.api_act_cancel_queued_sms pk

        body =
            [ ( "cancel_sms", Encode.bool True ) ]
    in
    rawPost csrf url body
        |> Http.send (StoreMsg << ReceiveLazy)


groupMembership : CSRFToken -> Int -> Int -> Bool -> Cmd Msg
groupMembership csrf groupPk contactPk isMember =
    let
        body =
            [ ( "member", Encode.bool isMember )
            , ( "contactPk", Encode.int contactPk )
            ]

        url =
            Urls.api_act_update_group_members groupPk
    in
    post csrf url body decodeRecipientGroup
        |> Http.send (StoreMsg << ReceiveToggleGroupMembership)


elvantoGroupSync : CSRFToken -> ElvantoGroup -> Cmd Msg
elvantoGroupSync csrf group =
    let
        url =
            Urls.api_toggle_elvanto_group_sync group.pk

        body =
            [ ( "sync", Encode.bool group.sync ) ]
    in
    post csrf url body decodeElvantoGroup
        |> Http.send (Messages.StoreMsg << ReceiveToggleElvantoGroupSync)
