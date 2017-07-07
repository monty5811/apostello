module Pages.Forms.UserProfile.View exposing (view)

import Data exposing (UserProfile)
import DjangoSend exposing (CSRFToken)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (..)
import Html exposing (Html)
import Messages exposing (FormMsg(PostForm, UserProfileFormMsg), Msg(FormMsg))
import Pages.Forms.UserProfile.Messages exposing (UserProfileFormMsg(..))
import Pages.Forms.UserProfile.Meta exposing (meta)
import Pages.Forms.UserProfile.Model exposing (UserProfileFormModel)
import Pages.Forms.UserProfile.Remote exposing (postCmd)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL


view : CSRFToken -> Int -> RL.RemoteList UserProfile -> UserProfileFormModel -> FormStatus -> Html Msg
view csrf pk profiles_ model status =
    let
        profiles =
            RL.toList profiles_

        currentProfile =
            profiles
                |> List.filter (\x -> x.user.pk == pk)
                |> List.head
    in
    case currentProfile of
        Nothing ->
            loader

        Just prof ->
            viewHelp csrf model status prof


viewHelp : CSRFToken -> UserProfileFormModel -> FormStatus -> UserProfile -> Html Msg
viewHelp csrf model status profile =
    let
        fields =
            [ Field meta.approved (approvedField profile)
            , Field meta.message_cost_limit (simpleFloatField meta.message_cost_limit (Just profile.message_cost_limit) (FormMsg << UserProfileFormMsg << UpdateMessageCostLimit))
            , Field meta.can_see_groups (checkboxField meta.can_see_groups (Just profile) .can_see_groups (FormMsg << UserProfileFormMsg << UpdateCanSeeGroups))
            , Field meta.can_see_contact_names (checkboxField meta.can_see_contact_names (Just profile) .can_see_contact_names (FormMsg << UserProfileFormMsg << UpdateCanSeeContactNames))
            , Field meta.can_see_keywords (checkboxField meta.can_see_keywords (Just profile) .can_see_keywords (FormMsg << UserProfileFormMsg << UpdateCanSeeKeywords))
            , Field meta.can_see_outgoing (checkboxField meta.can_see_outgoing (Just profile) .can_see_outgoing (FormMsg << UserProfileFormMsg << UpdateCanSeeOutgoing))
            , Field meta.can_see_incoming (checkboxField meta.can_see_incoming (Just profile) .can_see_incoming (FormMsg << UserProfileFormMsg << UpdateCanSeeIncoming))
            , Field meta.can_send_sms (checkboxField meta.can_send_sms (Just profile) .can_send_sms (FormMsg << UserProfileFormMsg << UpdateCanSendSms))
            , Field meta.can_see_contact_nums (checkboxField meta.can_see_contact_nums (Just profile) .can_see_contact_nums (FormMsg << UserProfileFormMsg << UpdateCanSeeContactNums))
            , Field meta.can_import (checkboxField meta.can_import (Just profile) .can_import (FormMsg << UserProfileFormMsg << UpdateCanImport))
            , Field meta.can_archive (checkboxField meta.can_archive (Just profile) .can_archive (FormMsg << UserProfileFormMsg << UpdateCanArchive))
            ]
                |> List.map FormField
    in
    Html.div []
        [ Html.h3 [] [ Html.text <| "User Profile: " ++ profile.user.email ]
        , form status
            fields
            (submitMsg csrf model profile)
            (submitButton (Just profile) False)
        ]


submitMsg : CSRFToken -> UserProfileFormModel -> UserProfile -> Msg
submitMsg csrf model profile =
    FormMsg <| PostForm <| postCmd csrf model profile


approvedField : UserProfile -> List (Html Msg)
approvedField profile =
    checkboxField
        meta.approved
        (Just profile)
        .approved
        (FormMsg << UserProfileFormMsg << UpdateApproved)
