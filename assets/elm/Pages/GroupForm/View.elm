module Pages.GroupForm.View exposing (view)

import Data.Recipient exposing (RecipientSimple)
import Data.RecipientGroup exposing (RecipientGroup)
import Data.Request exposing (StoreMsg(ToggleGroupMembership))
import Data.Store as Store
import FilteringTable.Util exposing (filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (..)
import Helpers exposing (onClick)
import Html exposing (Html, a, br, div, h3, h4, i, input, p, text)
import Html.Attributes as A
import Html.Events exposing (onInput)
import Messages exposing (FormMsg(PostGroupForm), Msg(FormMsg, GroupFormMsg, Nope, StoreMsg))
import Pages exposing (Page(GroupForm))
import Pages.GroupForm.Messages exposing (GroupFormMsg(..))
import Pages.GroupForm.Meta exposing (meta)
import Pages.GroupForm.Model exposing (GroupFormModel, initialGroupFormModel)
import Regex
import Route exposing (spaLink)


-- Main view


view : Maybe Int -> Store.RemoteList RecipientGroup -> GroupFormModel -> FormStatus -> Html Msg
view maybePk groups_ model status =
    let
        groups =
            Store.toList groups_

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
    div []
        [ archiveNotice showAN groups model.name
        , form status fields (submitMsg showAN model currentGroup) (submitButton currentGroup showAN)
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
            text ""

        True ->
            div [ A.class "ui message" ]
                [ p [] [ text "There is already a Group that with that name in the archive" ]
                , p [] [ text "You can chose a different name." ]
                , p []
                    [ text "Or you can restore the group here: "
                    , spaLink a [] [ text "Archived Group" ] <| GroupForm initialGroupFormModel matchedGroup
                    ]
                ]


nameField : FieldMeta -> Maybe RecipientGroup -> List (Html Msg)
nameField meta maybeGroup =
    simpleTextField meta
        (Maybe.map .name maybeGroup)
        (GroupFormMsg << UpdateGroupNameField)


descField : FieldMeta -> Maybe RecipientGroup -> List (Html Msg)
descField meta maybeGroup =
    simpleTextField meta
        (Maybe.map .description maybeGroup)
        (GroupFormMsg << UpdateGroupDescField)


submitMsg : Bool -> GroupFormModel -> Maybe RecipientGroup -> Msg
submitMsg showAN model maybeGroup =
    case showAN of
        True ->
            Nope

        False ->
            FormMsg <| PostGroupForm model maybeGroup


membershipToggles : Maybe RecipientGroup -> GroupFormModel -> Html Msg
membershipToggles maybeGroup model =
    case maybeGroup of
        Nothing ->
            div [] []

        Just group ->
            div []
                [ br [] []
                , h3 [] [ text "Group Members" ]
                , p [] [ text "Click a person to toggle their membership." ]
                , div [ A.class "ui two column celled grid" ]
                    [ div [ A.class "ui column" ]
                        [ h4 [] [ text "Non-Members" ]
                        , div []
                            [ filter (GroupFormMsg << UpdateNonMemberFilter)
                            , cardContainer model.nonmembersFilterRegex group.nonmembers group
                            ]
                        ]
                    , div [ A.class "ui column" ]
                        [ h4 [] [ text "Members" ]
                        , div []
                            [ filter (GroupFormMsg << UpdateMemberFilter)
                            , cardContainer model.membersFilterRegex group.members group
                            ]
                        ]
                    ]
                ]


filter : (String -> Msg) -> Html Msg
filter handleInput =
    div [ A.class "ui left icon large transparent fluid input" ]
        [ input [ A.placeholder "Filter...", A.type_ "text", onInput handleInput ] []
        , i [ A.class "violet filter icon" ] []
        ]


cardContainer : Regex.Regex -> List RecipientSimple -> RecipientGroup -> Html Msg
cardContainer filterRegex contacts group =
    div []
        [ br [] []
        , div [ A.class "ui three stackable cards" ]
            (contacts
                |> List.filter (filterRecord filterRegex)
                |> List.map (card group)
            )
        ]


card : RecipientGroup -> RecipientSimple -> Html Msg
card group contact =
    div [ A.class "ui raised card" ]
        [ div [ A.class "content", onClick (StoreMsg <| ToggleGroupMembership group contact) ]
            [ text contact.full_name ]
        ]
