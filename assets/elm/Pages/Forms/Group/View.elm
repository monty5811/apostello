module Pages.Forms.Group.View exposing (view)

import Data.Recipient exposing (RecipientSimple)
import Data.RecipientGroup exposing (RecipientGroup)
import DjangoSend exposing (CSRFToken)
import FilteringTable.Util exposing (filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (..)
import Helpers exposing (onClick)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onInput)
import Messages exposing (FormMsg(GroupFormMsg, PostForm), Msg(FormMsg, Nope, StoreMsg))
import Pages exposing (Page(GroupForm))
import Pages.Forms.Group.Messages exposing (GroupFormMsg(..))
import Pages.Forms.Group.Meta exposing (meta)
import Pages.Forms.Group.Model exposing (GroupFormModel, initialGroupFormModel)
import Pages.Forms.Group.Remote exposing (postCmd)
import Regex
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleGroupMembership))
import Store.RemoteList as RL


-- Main view


view : CSRFToken -> Maybe Int -> RL.RemoteList RecipientGroup -> GroupFormModel -> FormStatus -> Html Msg
view csrf maybePk groups_ model status =
    let
        groups =
            RL.toList groups_

        pk =
            Maybe.withDefault 0 maybePk

        currentGroup =
            groups
                |> List.filter (\x -> x.pk == pk)
                |> List.head

        showAN =
            showArchiveNotice groups currentGroup model

        fields =
            [ Field meta.name (nameField meta.name currentGroup)
            , Field meta.description (descField meta.description currentGroup)
            ]
    in
    Html.div []
        [ archiveNotice showAN groups model.name
        , form status fields (submitMsg csrf showAN model currentGroup) (submitButton currentGroup showAN)
        , membershipToggles currentGroup model
        ]


showArchiveNotice : List RecipientGroup -> Maybe RecipientGroup -> GroupFormModel -> Bool
showArchiveNotice groups maybeGroup model =
    let
        originalName =
            Maybe.map .name maybeGroup
                |> Maybe.withDefault ""

        currentProposedName =
            model.name
                |> Maybe.withDefault ""

        archivedNames =
            groups
                |> List.filter .is_archived
                |> List.map .name
    in
    case originalName == currentProposedName of
        True ->
            False

        False ->
            List.member currentProposedName archivedNames


archiveNotice : Bool -> List RecipientGroup -> Maybe String -> Html Msg
archiveNotice show groups name =
    let
        matchedGroup =
            groups
                |> List.filter (\g -> g.name == Maybe.withDefault "" name)
                |> List.head
                |> Maybe.map .pk
    in
    case show of
        False ->
            Html.text ""

        True ->
            Html.div [ A.class "ui message" ]
                [ Html.p [] [ Html.text "There is already a Group that with that name in the archive" ]
                , Html.p [] [ Html.text "You can chose a different name." ]
                , Html.p []
                    [ Html.text "Or you can restore the group here: "
                    , spaLink Html.a [] [ Html.text "Archived Group" ] <| GroupForm initialGroupFormModel matchedGroup
                    ]
                ]


nameField : FieldMeta -> Maybe RecipientGroup -> List (Html Msg)
nameField meta_ maybeGroup =
    simpleTextField meta_
        (Maybe.map .name maybeGroup)
        (FormMsg << GroupFormMsg << UpdateGroupNameField)


descField : FieldMeta -> Maybe RecipientGroup -> List (Html Msg)
descField meta_ maybeGroup =
    simpleTextField meta_
        (Maybe.map .description maybeGroup)
        (FormMsg << GroupFormMsg << UpdateGroupDescField)


submitMsg : CSRFToken -> Bool -> GroupFormModel -> Maybe RecipientGroup -> Msg
submitMsg csrf showAN model maybeGroup =
    case showAN of
        True ->
            Nope

        False ->
            FormMsg <| PostForm <| postCmd csrf model maybeGroup


membershipToggles : Maybe RecipientGroup -> GroupFormModel -> Html Msg
membershipToggles maybeGroup model =
    case maybeGroup of
        Nothing ->
            Html.div [] []

        Just group ->
            Html.div []
                [ Html.br [] []
                , Html.h3 [] [ Html.text "Group Members" ]
                , Html.p [] [ Html.text "Click a person to toggle their membership." ]
                , Html.div [ A.class "ui two column celled grid" ]
                    [ Html.div [ A.class "ui column" ]
                        [ Html.h4 [] [ Html.text "Non-Members" ]
                        , Html.div []
                            [ filter (FormMsg << GroupFormMsg << UpdateNonMemberFilter)
                            , cardContainer model.nonmembersFilterRegex group.nonmembers group
                            ]
                        ]
                    , Html.div [ A.class "ui column" ]
                        [ Html.h4 [] [ Html.text "Members" ]
                        , Html.div []
                            [ filter (FormMsg << GroupFormMsg << UpdateMemberFilter)
                            , cardContainer model.membersFilterRegex group.members group
                            ]
                        ]
                    ]
                ]


filter : (String -> Msg) -> Html Msg
filter handleInput =
    Html.div [ A.class "ui left icon large transparent fluid input" ]
        [ Html.input [ A.placeholder "Filter...", A.type_ "text", onInput handleInput ] []
        , Html.i [ A.class "violet filter icon" ] []
        ]


cardContainer : Regex.Regex -> List RecipientSimple -> RecipientGroup -> Html Msg
cardContainer filterRegex contacts group =
    Html.div []
        [ Html.br [] []
        , Html.div [ A.class "ui three stackable cards" ]
            (contacts
                |> List.filter (filterRecord filterRegex)
                |> List.map (card group)
            )
        ]


card : RecipientGroup -> RecipientSimple -> Html Msg
card group contact =
    Html.div [ A.class "ui raised card" ]
        [ Html.div [ A.class "content", onClick (StoreMsg <| ToggleGroupMembership group contact) ]
            [ Html.text contact.full_name ]
        ]
