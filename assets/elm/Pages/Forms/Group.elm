module Pages.Forms.Group exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (RecipientGroup, RecipientSimple)
import FilteringTable exposing (filterInput, filterRecord, textToRegex)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus(NoAction))
import Forms.View exposing (..)
import Helpers exposing (onClick)
import Html exposing (Html)
import Html.Attributes as A
import Pages.Error404 as E404
import Pages.Forms.Meta.Group exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL


type alias Model =
    { membersFilterRegex : Regex.Regex
    , nonmembersFilterRegex : Regex.Regex
    , name : Maybe String
    , description : Maybe String
    }


initialModel : Model
initialModel =
    { membersFilterRegex = Regex.regex ""
    , nonmembersFilterRegex = Regex.regex ""
    , name = Nothing
    , description = Nothing
    }



-- Update


type Msg
    = UpdateMemberFilter String
    | UpdateNonMemberFilter String
    | UpdateGroupNameField String
    | UpdateGroupDescField String


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateMemberFilter text ->
            { model | membersFilterRegex = textToRegex text }

        UpdateNonMemberFilter text ->
            { model | nonmembersFilterRegex = textToRegex text }

        UpdateGroupDescField text ->
            { model | description = Just text }

        UpdateGroupNameField text ->
            { model | name = Just text }



-- View


type alias Props msg =
    { form : Msg -> msg
    , postForm : msg
    , noop : msg
    , toggleGroupMembership : RecipientGroup -> RecipientSimple -> msg
    , restoreGroupLink : Maybe Int -> Html msg
    }


view : Props msg -> Maybe Int -> RL.RemoteList RecipientGroup -> Model -> FormStatus -> Html msg
view props maybePk groups model status =
    case maybePk of
        Nothing ->
            -- creating a new group
            creating props groups model status

        Just pk ->
            -- trying to edit an existing group:
            editing props pk groups model status


creating : Props msg -> RL.RemoteList RecipientGroup -> Model -> FormStatus -> Html msg
creating props groups model status =
    viewHelp props Nothing groups model status


editing : Props msg -> Int -> RL.RemoteList RecipientGroup -> Model -> FormStatus -> Html msg
editing props pk groups model status =
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
            viewHelp props (Just grp) groups model status

        Nothing ->
            -- group does not exist:
            case groups of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : Props msg -> Maybe RecipientGroup -> RL.RemoteList RecipientGroup -> Model -> FormStatus -> Html msg
viewHelp props currentGroup groups_ model status =
    let
        groups =
            RL.toList groups_

        showAN =
            showArchiveNotice groups currentGroup model

        fields =
            [ Field meta.name (nameField props currentGroup)
            , Field meta.description (descField props currentGroup)
            ]
                |> List.map FormField
    in
    Html.div []
        [ archiveNotice props showAN groups model.name
        , form status fields (submitMsg props showAN) (submitButton currentGroup showAN)
        , membershipToggles props currentGroup model
        ]


showArchiveNotice : List RecipientGroup -> Maybe RecipientGroup -> Model -> Bool
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


archiveNotice : Props msg -> Bool -> List RecipientGroup -> Maybe String -> Html msg
archiveNotice props show groups name =
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
            Html.div [ Css.alert, Css.alert_info ]
                [ Html.p [] [ Html.text "There is already a Group that with that name in the archive" ]
                , Html.p [] [ Html.text "You can chose a different name." ]
                , Html.p []
                    [ Html.text "Or you can restore the group here: "
                    , props.restoreGroupLink matchedGroup
                    ]
                ]


nameField : Props msg -> Maybe RecipientGroup -> (FieldMeta -> List (Html msg))
nameField props maybeGroup =
    simpleTextField
        (Maybe.map .name maybeGroup)
        (props.form << UpdateGroupNameField)


descField : Props msg -> Maybe RecipientGroup -> (FieldMeta -> List (Html msg))
descField props maybeGroup =
    simpleTextField
        (Maybe.map .description maybeGroup)
        (props.form << UpdateGroupDescField)


submitMsg : Props msg -> Bool -> msg
submitMsg props showAN =
    case showAN of
        True ->
            props.noop

        False ->
            props.postForm


membershipToggles : Props msg -> Maybe RecipientGroup -> Model -> Html msg
membershipToggles props maybeGroup model =
    case maybeGroup of
        Nothing ->
            Html.div [] []

        Just group ->
            Html.div [ Css.max_w_md, Css.mx_auto ]
                [ Html.br [] []
                , Html.h3 [ Css.mb_2 ] [ Html.text "Group Members" ]
                , Html.p [ Css.mb_2 ] [ Html.text "Click a person to toggle their membership." ]
                , Html.div [ Css.flex ]
                    [ Html.div [ Css.flex_1 ]
                        [ Html.h4 [] [ Html.text "Non-Members" ]
                        , Html.div []
                            [ filterInput (props.form << UpdateNonMemberFilter)
                            , cardContainer props "nonmembers" model.nonmembersFilterRegex group.nonmembers group
                            ]
                        ]
                    , Html.div [ Css.flex_1 ]
                        [ Html.h4 [] [ Html.text "Members" ]
                        , Html.div []
                            [ filterInput (props.form << UpdateMemberFilter)
                            , cardContainer props "members" model.membersFilterRegex group.members group
                            ]
                        ]
                    ]
                ]


cardContainer : Props msg -> String -> Regex.Regex -> List RecipientSimple -> RecipientGroup -> Html msg
cardContainer props id_ filterRegex contacts group =
    Html.div [ Css.px_2 ]
        [ Html.br [] []
        , Html.div [ A.id <| id_ ++ "_list" ]
            (contacts
                |> List.filter (filterRecord filterRegex)
                |> List.map (card props id_ group)
            )
        ]


card : Props msg -> String -> RecipientGroup -> RecipientSimple -> Html msg
card props id_ group contact =
    Html.div [ A.id <| id_ ++ "_item", Css.border_b_2, Css.select_none, Css.cursor_pointer ]
        [ Html.div [ onClick (props.toggleGroupMembership group contact) ]
            [ Html.text contact.full_name ]
        ]
