module Pages.Forms.Group.View exposing (view)

import Data exposing (RecipientGroup, RecipientSimple)
import DjangoSend exposing (CSRFToken)
import FilteringTable exposing (filterInput, filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (..)
import Helpers exposing (onClick)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onInput)
import Messages exposing (FormMsg(GroupFormMsg, PostForm), Msg(FormMsg, Nope, StoreMsg))
import Pages exposing (Page(GroupForm))
import Pages.Error404 as E404
import Pages.Forms.Group.Messages exposing (GroupFormMsg(..))
import Pages.Forms.Group.Meta exposing (meta)
import Pages.Forms.Group.Model exposing (GroupFormModel, initialGroupFormModel)
import Pages.Forms.Group.Remote exposing (postCmd)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Rocket exposing ((=>))
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleGroupMembership))


-- Main view


view : CSRFToken -> Maybe Int -> RL.RemoteList RecipientGroup -> GroupFormModel -> FormStatus -> Html Msg
view csrf maybePk groups model status =
    case maybePk of
        Nothing ->
            -- creating a new group
            creating csrf groups model status

        Just pk ->
            -- trying to edit an existing group:
            editing csrf pk groups model status


creating : CSRFToken -> RL.RemoteList RecipientGroup -> GroupFormModel -> FormStatus -> Html Msg
creating csrf groups model status =
    viewHelp csrf Nothing groups model status


editing : CSRFToken -> Int -> RL.RemoteList RecipientGroup -> GroupFormModel -> FormStatus -> Html Msg
editing csrf pk groups model status =
    let
        currentGroup =
            groups
                |> RL.toList
                |> List.filter (\x -> x.pk == pk)
                |> List.head
    in
    case currentGroup of
        Just grp ->
            -- group exists, show the form:
            viewHelp csrf (Just grp) groups model status

        Nothing ->
            -- group does not exist:
            case groups of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : CSRFToken -> Maybe RecipientGroup -> RL.RemoteList RecipientGroup -> GroupFormModel -> FormStatus -> Html Msg
viewHelp csrf currentGroup groups_ model status =
    let
        groups =
            RL.toList groups_

        showAN =
            showArchiveNotice groups currentGroup model

        fields =
            [ Field meta.name (nameField meta.name currentGroup)
            , Field meta.description (descField meta.description currentGroup)
            ]
                |> List.map FormField
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
            Html.div [ A.class "alert" ]
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
                , Html.div
                    [ A.style
                        [ "display" => "grid"
                        , "grid-template-columns" => "50% 50%"
                        ]
                    ]
                    [ Html.div []
                        [ Html.h4 [] [ Html.text "Non-Members" ]
                        , Html.div []
                            [ filterInput (FormMsg << GroupFormMsg << UpdateNonMemberFilter)
                            , cardContainer "nonmembers" model.nonmembersFilterRegex group.nonmembers group
                            ]
                        ]
                    , Html.div []
                        [ Html.h4 [] [ Html.text "Members" ]
                        , Html.div []
                            [ filterInput (FormMsg << GroupFormMsg << UpdateMemberFilter)
                            , cardContainer "members" model.membersFilterRegex group.members group
                            ]
                        ]
                    ]
                ]


cardContainer : String -> Regex.Regex -> List RecipientSimple -> RecipientGroup -> Html Msg
cardContainer id_ filterRegex contacts group =
    Html.div []
        [ Html.br [] []
        , Html.div [ A.class "list", A.id <| id_ ++ "_list" ]
            (contacts
                |> List.filter (filterRecord filterRegex)
                |> List.map (card id_ group)
            )
        ]


card : String -> RecipientGroup -> RecipientSimple -> Html Msg
card id_ group contact =
    Html.div [ A.class "item", A.id <| id_ ++ "_item" ]
        [ Html.div [ onClick (StoreMsg <| ToggleGroupMembership group contact) ]
            [ Html.text contact.full_name ]
        ]
