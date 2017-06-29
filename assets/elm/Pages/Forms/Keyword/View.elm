module Pages.Forms.Keyword.View exposing (view)

import Data.Keyword exposing (Keyword)
import Data.RecipientGroup exposing (RecipientGroup)
import Data.User exposing (User)
import Date
import DateTimePicker
import DjangoSend exposing (CSRFToken)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Messages exposing (FormMsg(KeywordFormMsg, PostForm), Msg(FormMsg, Nope))
import Pages exposing (Page(KeywordForm))
import Pages.Error404 as E404
import Pages.Forms.Keyword.Messages exposing (KeywordFormMsg(..))
import Pages.Forms.Keyword.Meta exposing (meta)
import Pages.Forms.Keyword.Model exposing (KeywordFormModel, initialKeywordFormModel)
import Pages.Forms.Keyword.Remote exposing (postCmd)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL
import Route exposing (spaLink)
import Store.Model exposing (DataStore, filterArchived)
import Time


-- Main view


view : CSRFToken -> Time.Time -> DataStore -> Maybe String -> KeywordFormModel -> FormStatus -> Html Msg
view csrf now dataStore maybeK model status =
    case maybeK of
        Nothing ->
            -- creating a new keyword:
            creating csrf now dataStore model status

        Just k ->
            -- trying to edit an existing keyword:
            editing csrf now dataStore k model status


creating : CSRFToken -> Time.Time -> DataStore -> KeywordFormModel -> FormStatus -> Html Msg
creating csrf now dataStore model status =
    viewHelp csrf now dataStore Nothing model status


editing : CSRFToken -> Time.Time -> DataStore -> String -> KeywordFormModel -> FormStatus -> Html Msg
editing csrf now dataStore keyword model status =
    let
        currentKeyword =
            dataStore.keywords
                |> RL.toList
                |> List.filter (\x -> x.keyword == keyword)
                |> List.head
    in
    case currentKeyword of
        Just k ->
            -- keyword exists, show the form:
            viewHelp csrf now dataStore (Just k) model status

        Nothing ->
            -- keyword does not exist:
            case dataStore.keywords of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : CSRFToken -> Time.Time -> DataStore -> Maybe Keyword -> KeywordFormModel -> FormStatus -> Html Msg
viewHelp csrf now dataStore currentKeyword model status =
    let
        keywords =
            RL.toList dataStore.keywords

        groups =
            filterArchived False dataStore.groups

        users =
            dataStore.users

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
    Html.div []
        [ archiveNotice showAN keywords model.keyword
        , form status fields (submitMsg csrf now showAN model currentKeyword) (submitButton currentKeyword showAN)
        ]


keywordField : FieldMeta -> Maybe Keyword -> List (Html Msg)
keywordField meta_ maybeKeyword =
    simpleTextField meta_
        (Maybe.map .keyword maybeKeyword)
        (FormMsg << KeywordFormMsg << UpdateKeywordKeywordField)


descField : FieldMeta -> Maybe Keyword -> List (Html Msg)
descField meta_ maybeKeyword =
    simpleTextField meta_
        (Maybe.map .description maybeKeyword)
        (FormMsg << KeywordFormMsg << UpdateKeywordDescField)


disableRepliesField : FieldMeta -> Maybe Keyword -> List (Html Msg)
disableRepliesField meta_ maybeKeyword =
    checkboxField meta_
        maybeKeyword
        .disable_all_replies
        (FormMsg << KeywordFormMsg << UpdateKeywordDisableRepliesField)


customRespField : FieldMeta -> Maybe Keyword -> List (Html Msg)
customRespField meta_ maybeKeyword =
    simpleTextField meta_ (Maybe.map .custom_response maybeKeyword) (FormMsg << KeywordFormMsg << UpdateKeywordCustRespField)


deactivatedRespField : FieldMeta -> Maybe Keyword -> List (Html Msg)
deactivatedRespField meta_ maybeKeyword =
    simpleTextField meta_ (Maybe.map .deactivated_response maybeKeyword) (FormMsg << KeywordFormMsg << UpdateKeywordDeacRespField)


tooEarlyRespField : FieldMeta -> Maybe Keyword -> List (Html Msg)
tooEarlyRespField meta_ maybeKeyword =
    simpleTextField meta_ (Maybe.map .custom_response maybeKeyword) (FormMsg << KeywordFormMsg << UpdateKeywordTooEarlyRespField)


activateTimeField : FieldMeta -> KeywordFormModel -> Maybe Keyword -> List (Html Msg)
activateTimeField meta_ model maybeKeyword =
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
    dateTimeField updateActTime meta_ model.datePickerActState time


updateActTime : DateTimePicker.State -> Maybe Date.Date -> Msg
updateActTime state maybeDate =
    FormMsg <| KeywordFormMsg <| UpdateActivateTime state maybeDate


deactivateTimeField : FieldMeta -> KeywordFormModel -> Maybe Keyword -> List (Html Msg)
deactivateTimeField meta_ model maybeKeyword =
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
    dateTimeField updateDeactTime meta_ model.datePickerDeactState time


updateDeactTime : DateTimePicker.State -> Maybe Date.Date -> Msg
updateDeactTime state maybeDate =
    FormMsg <| KeywordFormMsg <| UpdateDeactivateTime state maybeDate


linkedGroupsField : FieldMeta -> KeywordFormModel -> RL.RemoteList RecipientGroup -> Maybe Keyword -> List (Html Msg)
linkedGroupsField meta_ model groups maybeKeyword =
    multiSelectField
        meta_
        (MultiSelectField
            groups
            model.linked_groups
            (Maybe.map .linked_groups maybeKeyword)
            model.linkedGroupsFilter
            (FormMsg << KeywordFormMsg << UpdateKeywordLinkedGroupsFilter)
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
        [ A.class "item", E.onClick <| FormMsg <| KeywordFormMsg <| UpdateSelectedLinkedGroup selectedPks group.pk ]
        [ ( toString group.pk, groupViewHelper selectedPks group ) ]


groupViewHelper : List Int -> RecipientGroup -> Html Msg
groupViewHelper selectedPks group =
    Html.div [ A.class "content", A.style [ ( "color", "#000" ) ] ]
        [ selectedIcon selectedPks group
        , Html.text group.name
        ]


ownersField : FieldMeta -> KeywordFormModel -> RL.RemoteList User -> Maybe Keyword -> List (Html Msg)
ownersField meta_ model users maybeKeyword =
    multiSelectField
        meta_
        (MultiSelectField
            users
            model.owners
            (Maybe.map .owners maybeKeyword)
            model.ownersFilter
            (FormMsg << KeywordFormMsg << UpdateKeywordOwnersFilter)
            (userView UpdateSelectedOwner)
        )


digestField : FieldMeta -> KeywordFormModel -> RL.RemoteList User -> Maybe Keyword -> List (Html Msg)
digestField meta_ model users maybeKeyword =
    multiSelectField
        meta_
        (MultiSelectField
            users
            model.subscribers
            (Maybe.map .subscribed_to_digest maybeKeyword)
            model.subscribersFilter
            (FormMsg << KeywordFormMsg << UpdateKeywordSubscribersFilter)
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
        [ A.class "item", E.onClick <| FormMsg <| KeywordFormMsg <| msg selectedPks owner.pk ]
        [ ( toString owner.pk, userViewHelper selectedPks owner ) ]


userViewHelper : List Int -> User -> Html Msg
userViewHelper selectedPks owner =
    Html.div [ A.class "content", A.style [ ( "color", "#000" ) ] ]
        [ selectedIcon selectedPks owner
        , Html.text owner.email
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
            Html.text ""

        True ->
            Html.div [ A.class "ui message" ]
                [ Html.p [] [ Html.text "There is already a Keyword that with that name in the archive" ]
                , Html.p [] [ Html.text "You can chose a different name." ]
                , Html.p []
                    [ Html.text "Or you can restore the keyword here: "
                    , spaLink Html.a [] [ Html.text "Archived Keyword" ] <| KeywordForm initialKeywordFormModel matchedKeyword
                    ]
                ]


submitMsg : CSRFToken -> Time.Time -> Bool -> KeywordFormModel -> Maybe Keyword -> Msg
submitMsg csrf now showAN model maybeKeyword =
    case showAN of
        True ->
            Nope

        False ->
            FormMsg <| PostForm <| postCmd csrf now model maybeKeyword
