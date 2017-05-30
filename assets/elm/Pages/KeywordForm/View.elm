module Pages.KeywordForm.View exposing (view)

import Data.Keyword exposing (Keyword)
import Data.RecipientGroup exposing (RecipientGroup)
import Data.Store as Store
import Data.User exposing (User)
import Date
import DateTimePicker
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (..)
import Html exposing (Html, a, div, p, text)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Messages exposing (FormMsg(PostKeywordForm), Msg(FormMsg, KeywordFormMsg, Nope))
import Pages exposing (Page(KeywordForm))
import Pages.KeywordForm.Messages exposing (KeywordFormMsg(..))
import Pages.KeywordForm.Meta exposing (meta)
import Pages.KeywordForm.Model exposing (KeywordFormModel, initialKeywordFormModel)
import Route exposing (spaLink)


-- Main view


view : Store.DataStore -> Maybe String -> KeywordFormModel -> FormStatus -> Html Msg
view dataStore maybeK model status =
    let
        keywords =
            Store.toList dataStore.keywords

        groups =
            Store.filterArchived False dataStore.groups

        users =
            dataStore.users

        k =
            Maybe.withDefault "" maybeK

        currentKeyword =
            keywords
                |> List.filter (\x -> x.keyword == k)
                |> List.head

        showAN =
            showArchiveNotice keywords currentKeyword model

        fields =
            [ Field meta.keyword (keywordField meta.keyword currentKeyword)
            , Field meta.description (descField meta.description currentKeyword)
            , Field meta.disable_all_replies (disableRepliesField meta.disable_all_replies currentKeyword)
            , Field meta.custom_response (customRespField meta.custom_response currentKeyword)
            , Field meta.deactivated_response (deactivatedRespField meta.deactivated_response currentKeyword)
            , Field meta.too_early_response (tooEarlyRespField meta.too_early_response currentKeyword)
            , Field meta.activate_time (activateTimeField meta.activate_time model currentKeyword)
            , Field meta.deactivate_time (deactivateTimeField meta.deactivate_time model currentKeyword)
            , Field meta.linked_groups (linkedGroupsField meta.linked_groups model groups currentKeyword)
            , Field meta.owners (ownersField meta.owners model users currentKeyword)
            , Field meta.subscribed_to_digest (digestField meta.subscribed_to_digest model users currentKeyword)
            ]
    in
    div []
        [ archiveNotice showAN keywords model.keyword
        , form status fields (submitMsg showAN model currentKeyword) (submitButton currentKeyword showAN)
        ]


keywordField : FieldMeta -> Maybe Keyword -> List (Html Msg)
keywordField meta maybeKeyword =
    simpleTextField meta
        (Maybe.map .keyword maybeKeyword)
        (KeywordFormMsg << UpdateKeywordKeywordField)


descField : FieldMeta -> Maybe Keyword -> List (Html Msg)
descField meta maybeKeyword =
    simpleTextField meta
        (Maybe.map .description maybeKeyword)
        (KeywordFormMsg << UpdateKeywordDescField)


disableRepliesField : FieldMeta -> Maybe Keyword -> List (Html Msg)
disableRepliesField meta maybeKeyword =
    checkboxField meta
        maybeKeyword
        .disable_all_replies
        (KeywordFormMsg << UpdateKeywordDisableRepliesField)


customRespField : FieldMeta -> Maybe Keyword -> List (Html Msg)
customRespField meta maybeKeyword =
    simpleTextField meta (Maybe.map .custom_response maybeKeyword) (KeywordFormMsg << UpdateKeywordCustRespField)


deactivatedRespField : FieldMeta -> Maybe Keyword -> List (Html Msg)
deactivatedRespField meta maybeKeyword =
    simpleTextField meta (Maybe.map .deactivated_response maybeKeyword) (KeywordFormMsg << UpdateKeywordDeacRespField)


tooEarlyRespField : FieldMeta -> Maybe Keyword -> List (Html Msg)
tooEarlyRespField meta maybeKeyword =
    simpleTextField meta (Maybe.map .custom_response maybeKeyword) (KeywordFormMsg << UpdateKeywordTooEarlyRespField)


activateTimeField : FieldMeta -> KeywordFormModel -> Maybe Keyword -> List (Html Msg)
activateTimeField meta model maybeKeyword =
    let
        time =
            case model.activate_time of
                Nothing ->
                    case maybeKeyword of
                        Nothing ->
                            Nothing

                        Just k ->
                            Just k.activate_time

                Just t ->
                    Just t
    in
    dateTimeField updateActTime meta model.datePickerActState time


updateActTime : DateTimePicker.State -> Maybe Date.Date -> Msg
updateActTime state maybeDate =
    KeywordFormMsg <| UpdateActivateTime state maybeDate


deactivateTimeField : FieldMeta -> KeywordFormModel -> Maybe Keyword -> List (Html Msg)
deactivateTimeField meta model maybeKeyword =
    let
        time =
            case model.deactivate_time of
                Nothing ->
                    case maybeKeyword of
                        Nothing ->
                            Nothing

                        Just k ->
                            k.deactivate_time

                Just t ->
                    Just t
    in
    dateTimeField updateDeactTime meta model.datePickerDeactState time


updateDeactTime : DateTimePicker.State -> Maybe Date.Date -> Msg
updateDeactTime state maybeDate =
    KeywordFormMsg <| UpdateDeactivateTime state maybeDate


linkedGroupsField : FieldMeta -> KeywordFormModel -> Store.RemoteList RecipientGroup -> Maybe Keyword -> List (Html Msg)
linkedGroupsField meta model groups maybeKeyword =
    multiSelectField
        meta
        (MultiSelectField
            groups
            model.linked_groups
            (Maybe.map .linked_groups maybeKeyword)
            model.linkedGroupsFilter
            (KeywordFormMsg << UpdateKeywordLinkedGroupsFilter)
            groupView
        )


groupView : Maybe (List Int) -> RecipientGroup -> Html Msg
groupView maybeSelectedPks group =
    let
        selectedPks =
            case maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks
    in
    Html.Keyed.node "div"
        [ A.class "item", E.onClick <| KeywordFormMsg <| UpdateSelectedLinkedGroup selectedPks group.pk ]
        [ ( toString group.pk, groupViewHelper selectedPks group ) ]


groupViewHelper : List Int -> RecipientGroup -> Html Msg
groupViewHelper selectedPks group =
    div [ A.class "content", A.style [ ( "color", "#000" ) ] ]
        [ selectedIcon selectedPks group
        , text group.name
        ]


ownersField : FieldMeta -> KeywordFormModel -> Store.RemoteList User -> Maybe Keyword -> List (Html Msg)
ownersField meta model users maybeKeyword =
    multiSelectField
        meta
        (MultiSelectField
            users
            model.owners
            (Maybe.map .owners maybeKeyword)
            model.ownersFilter
            (KeywordFormMsg << UpdateKeywordOwnersFilter)
            (userView UpdateSelectedOwner)
        )


digestField : FieldMeta -> KeywordFormModel -> Store.RemoteList User -> Maybe Keyword -> List (Html Msg)
digestField meta model users maybeKeyword =
    multiSelectField
        meta
        (MultiSelectField
            users
            model.subscribers
            (Maybe.map .subscribed_to_digest maybeKeyword)
            model.subscribersFilter
            (KeywordFormMsg << UpdateKeywordSubscribersFilter)
            (userView UpdateSelectedSubscriber)
        )


userView : (List Int -> Int -> KeywordFormMsg) -> Maybe (List Int) -> User -> Html Msg
userView msg maybeSelectedPks owner =
    let
        selectedPks =
            case maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks
    in
    Html.Keyed.node "div"
        [ A.class "item", E.onClick <| KeywordFormMsg <| msg selectedPks owner.pk ]
        [ ( toString owner.pk, userViewHelper selectedPks owner ) ]


userViewHelper : List Int -> User -> Html Msg
userViewHelper selectedPks owner =
    div [ A.class "content", A.style [ ( "color", "#000" ) ] ]
        [ selectedIcon selectedPks owner
        , text owner.email
        ]


showArchiveNotice : List Keyword -> Maybe Keyword -> KeywordFormModel -> Bool
showArchiveNotice keywords maybeKeyword model =
    let
        originalName =
            Maybe.map .keyword maybeKeyword
                |> Maybe.withDefault ""

        currentProposedName =
            model.keyword
                |> Maybe.withDefault ""

        archivedNames =
            keywords
                |> List.filter .is_archived
                |> List.map .keyword
    in
    case originalName == currentProposedName of
        True ->
            False

        False ->
            List.member currentProposedName archivedNames


archiveNotice : Bool -> List Keyword -> Maybe String -> Html Msg
archiveNotice show keywords name =
    let
        matchedKeyword =
            keywords
                |> List.filter (\g -> g.keyword == Maybe.withDefault "" name)
                |> List.head
                |> Maybe.map .keyword
    in
    case show of
        False ->
            text ""

        True ->
            div [ A.class "ui message" ]
                [ p [] [ text "There is already a Keyword that with that name in the archive" ]
                , p [] [ text "You can chose a different name." ]
                , p []
                    [ text "Or you can restore the keyword here: "
                    , spaLink a [] [ text "Archived Keyword" ] <| KeywordForm initialKeywordFormModel matchedKeyword
                    ]
                ]


submitMsg : Bool -> KeywordFormModel -> Maybe Keyword -> Msg
submitMsg showAN model maybeKeyword =
    case showAN of
        True ->
            Nope

        False ->
            FormMsg <| PostKeywordForm model maybeKeyword
