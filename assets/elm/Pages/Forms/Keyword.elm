module Pages.Forms.Keyword exposing (..)

import Data exposing (Keyword, RecipientGroup, User)
import Date
import DateTimePicker
import FilteringTable exposing (textToRegex)
import Forms.Model exposing (Field, FieldMeta, FormItem(FieldGroup, FormField), FormStatus, defaultFieldGroupConfig)
import Forms.View exposing (..)
import Helpers exposing (toggleSelectedPk)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Pages.Error404 as E404
import Pages.Forms.Meta.Keyword exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Rocket exposing ((=>))


type alias Model =
    { keyword : Maybe String
    , description : Maybe String
    , disable_all_replies : Maybe Bool
    , custom_response : Maybe String
    , custom_response_new_person : Maybe String
    , deactivated_response : Maybe String
    , too_early_response : Maybe String
    , activate_time : Maybe Date.Date
    , datePickerActState : DateTimePicker.State
    , deactivate_time : Maybe Date.Date
    , datePickerDeactState : DateTimePicker.State
    , linkedGroupsFilter : Regex.Regex
    , linked_groups : Maybe (List Int)
    , ownersFilter : Regex.Regex
    , owners : Maybe (List Int)
    , subscribersFilter : Regex.Regex
    , subscribers : Maybe (List Int)
    }


initialModel : Model
initialModel =
    { keyword = Nothing
    , description = Nothing
    , disable_all_replies = Nothing
    , custom_response = Nothing
    , custom_response_new_person = Nothing
    , deactivated_response = Nothing
    , too_early_response = Nothing
    , activate_time = Nothing
    , datePickerActState = DateTimePicker.initialState
    , deactivate_time = Nothing
    , datePickerDeactState = DateTimePicker.initialState
    , linkedGroupsFilter = Regex.regex ""
    , linked_groups = Nothing
    , ownersFilter = Regex.regex ""
    , owners = Nothing
    , subscribersFilter = Regex.regex ""
    , subscribers = Nothing
    }


type Msg
    = UpdateKeywordKeywordField String
    | UpdateKeywordDescField String
    | UpdateKeywordDisableRepliesField (Maybe Keyword)
    | UpdateKeywordCustRespField String
    | UpdateKeywordCustNewPersonRespField String
    | UpdateKeywordDeacRespField String
    | UpdateKeywordTooEarlyRespField String
    | UpdateActivateTime DateTimePicker.State (Maybe Date.Date)
    | UpdateDeactivateTime DateTimePicker.State (Maybe Date.Date)
    | UpdateKeywordLinkedGroupsFilter String
    | UpdateSelectedLinkedGroup (List Int) Int
    | UpdateKeywordOwnersFilter String
    | UpdateSelectedOwner (List Int) Int
    | UpdateKeywordSubscribersFilter String
    | UpdateSelectedSubscriber (List Int) Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateKeywordKeywordField text ->
            { model | keyword = Just text }

        UpdateKeywordDescField text ->
            { model | description = Just text }

        UpdateKeywordDisableRepliesField maybeKeyword ->
            let
                b =
                    case model.disable_all_replies of
                        Just curVal ->
                            not curVal

                        Nothing ->
                            case maybeKeyword of
                                Nothing ->
                                    False

                                Just c ->
                                    not c.disable_all_replies
            in
            { model | disable_all_replies = Just b }

        UpdateKeywordCustRespField text ->
            { model | custom_response = Just text }

        UpdateKeywordCustNewPersonRespField text ->
            { model | custom_response_new_person = Just text }

        UpdateKeywordDeacRespField text ->
            { model | deactivated_response = Just text }

        UpdateKeywordTooEarlyRespField text ->
            { model | too_early_response = Just text }

        UpdateActivateTime state maybeDate ->
            { model | activate_time = maybeDate, datePickerActState = state }

        UpdateDeactivateTime state maybeDate ->
            { model | deactivate_time = maybeDate, datePickerDeactState = state }

        UpdateKeywordLinkedGroupsFilter text ->
            { model | linkedGroupsFilter = textToRegex text }

        UpdateSelectedLinkedGroup pks pk ->
            { model | linked_groups = Just <| toggleSelectedPk pk pks }

        UpdateKeywordOwnersFilter text ->
            { model | ownersFilter = textToRegex text }

        UpdateSelectedOwner pks pk ->
            { model | owners = Just <| toggleSelectedPk pk pks }

        UpdateKeywordSubscribersFilter text ->
            { model | subscribersFilter = textToRegex text }

        UpdateSelectedSubscriber pks pk ->
            { model | subscribers = Just <| toggleSelectedPk pk pks }



-- View


type alias Messages msg =
    { postForm : msg
    , k : Msg -> msg
    , noop : msg
    , spa : Maybe String -> Html msg
    }


view : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> Maybe String -> Model -> FormStatus -> Html msg
view msgs keywords groups users maybeK model status =
    case maybeK of
        Nothing ->
            -- creating a new keyword:
            creating msgs keywords groups users model status

        Just k ->
            -- trying to edit an existing keyword:
            editing msgs keywords groups users k model status


creating : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> Model -> FormStatus -> Html msg
creating msgs keywords groups users model status =
    viewHelp msgs keywords groups users Nothing model status


editing : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> String -> Model -> FormStatus -> Html msg
editing msgs keywords groups users keyword model status =
    let
        currentKeyword =
            keywords
                |> RL.toList
                |> List.filter (\x -> x.keyword == keyword)
                |> List.head
    in
    case currentKeyword of
        Just k ->
            -- keyword exists, show the form:
            viewHelp msgs keywords groups users (Just k) model status

        Nothing ->
            -- keyword does not exist:
            case keywords of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> Maybe Keyword -> Model -> FormStatus -> Html msg
viewHelp msgs keywords_ groups users currentKeyword model status =
    let
        keywords =
            RL.toList keywords_

        showAN =
            showArchiveNotice keywords currentKeyword model

        fields =
            [ FormField <| Field meta.keyword (keywordField msgs currentKeyword)
            , FormField <| Field meta.description (descField msgs currentKeyword)
            , FormField <| Field meta.disable_all_replies (disableRepliesField msgs currentKeyword)
            , FieldGroup { defaultFieldGroupConfig | header = Just "Replies" }
                [ Field meta.custom_response (customRespField msgs currentKeyword)
                , Field meta.custom_response_new_person (customRespNewPersonField msgs currentKeyword)
                , Field meta.deactivated_response (deactivatedRespField msgs currentKeyword)
                , Field meta.too_early_response (tooEarlyRespField msgs currentKeyword)
                ]
            , FieldGroup { defaultFieldGroupConfig | header = Just "Scheduling" }
                [ Field meta.activate_time (activateTimeField msgs model currentKeyword)
                , Field meta.deactivate_time (deactivateTimeField msgs model currentKeyword)
                ]
            , FieldGroup { defaultFieldGroupConfig | header = Just "Other Settings" }
                [ Field meta.linked_groups (linkedGroupsField msgs model groups currentKeyword)
                , Field meta.owners (ownersField msgs model users currentKeyword)
                , Field meta.subscribed_to_digest (digestField msgs model users currentKeyword)
                ]
            ]
    in
    Html.div []
        [ archiveNotice msgs showAN keywords model.keyword
        , form status fields (submitMsg msgs showAN) (submitButton currentKeyword showAN)
        ]


keywordField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
keywordField msgs maybeKeyword =
    simpleTextField
        (Maybe.map .keyword maybeKeyword)
        (msgs.k << UpdateKeywordKeywordField)


descField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
descField msgs maybeKeyword =
    simpleTextField
        (Maybe.map .description maybeKeyword)
        (msgs.k << UpdateKeywordDescField)


disableRepliesField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
disableRepliesField msgs maybeKeyword =
    checkboxField
        maybeKeyword
        .disable_all_replies
        (msgs.k << UpdateKeywordDisableRepliesField)


customRespField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
customRespField msgs maybeKeyword =
    simpleTextField (Maybe.map .custom_response maybeKeyword) (msgs.k << UpdateKeywordCustRespField)


customRespNewPersonField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
customRespNewPersonField msgs maybeKeyword =
    simpleTextField (Maybe.map .custom_response_new_person maybeKeyword) (msgs.k << UpdateKeywordCustNewPersonRespField)


deactivatedRespField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
deactivatedRespField msgs maybeKeyword =
    simpleTextField (Maybe.map .deactivated_response maybeKeyword) (msgs.k << UpdateKeywordDeacRespField)


tooEarlyRespField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
tooEarlyRespField msgs maybeKeyword =
    simpleTextField (Maybe.map .custom_response maybeKeyword) (msgs.k << UpdateKeywordTooEarlyRespField)


activateTimeField : Messages msg -> Model -> Maybe Keyword -> FieldMeta -> List (Html msg)
activateTimeField msgs model maybeKeyword =
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
    dateTimeField (updateActTime msgs) model.datePickerActState time


updateActTime : Messages msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateActTime msgs state maybeDate =
    msgs.k <| UpdateActivateTime state maybeDate


deactivateTimeField : Messages msg -> Model -> Maybe Keyword -> FieldMeta -> List (Html msg)
deactivateTimeField msgs model maybeKeyword =
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
    dateTimeField (updateDeactTime msgs) model.datePickerDeactState time


updateDeactTime : Messages msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateDeactTime msgs state maybeDate =
    msgs.k <| UpdateDeactivateTime state maybeDate


linkedGroupsField : Messages msg -> Model -> RL.RemoteList RecipientGroup -> Maybe Keyword -> FieldMeta -> List (Html msg)
linkedGroupsField msgs model groups maybeKeyword =
    multiSelectField
        (MultiSelectField
            groups
            model.linked_groups
            (Maybe.map .linked_groups maybeKeyword)
            model.linkedGroupsFilter
            (msgs.k << UpdateKeywordLinkedGroupsFilter)
            (groupView msgs)
            (groupLabelView msgs)
        )


groupLabelView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupLabelView msgs maybePks group =
    Html.div
        [ A.class "badge"
        , A.style [ "user-select" => "none" ]
        , E.onClick <| msgs.k <| UpdateSelectedLinkedGroup (Maybe.withDefault [] maybePks) group.pk
        ]
        [ Html.text group.name ]


groupView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupView msgs maybeSelectedPks group =
    let
        selectedPks =
            case maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks
    in
    Html.Keyed.node "div"
        [ A.class "item"
        , A.style [ "user-select" => "none" ]
        , E.onClick <| msgs.k <| UpdateSelectedLinkedGroup selectedPks group.pk
        ]
        [ toString group.pk => groupViewHelper selectedPks group ]


groupViewHelper : List Int -> RecipientGroup -> Html msg
groupViewHelper selectedPks group =
    Html.div [ A.style [ "color" => "#000" ] ]
        [ selectedIcon selectedPks group
        , Html.text group.name
        ]


ownersField : Messages msg -> Model -> RL.RemoteList User -> Maybe Keyword -> FieldMeta -> List (Html msg)
ownersField msgs model users maybeKeyword =
    multiSelectField
        (MultiSelectField
            users
            model.owners
            (Maybe.map .owners maybeKeyword)
            model.ownersFilter
            (msgs.k << UpdateKeywordOwnersFilter)
            (userView msgs UpdateSelectedOwner)
            (userLabelView msgs UpdateSelectedOwner)
        )


digestField : Messages msg -> Model -> RL.RemoteList User -> Maybe Keyword -> FieldMeta -> List (Html msg)
digestField msgs model users maybeKeyword =
    multiSelectField
        (MultiSelectField
            users
            model.subscribers
            (Maybe.map .subscribed_to_digest maybeKeyword)
            model.subscribersFilter
            (msgs.k << UpdateKeywordSubscribersFilter)
            (userView msgs UpdateSelectedSubscriber)
            (userLabelView msgs UpdateSelectedSubscriber)
        )


userLabelView : Messages msg -> (List Int -> Int -> Msg) -> Maybe (List Int) -> User -> Html msg
userLabelView msgs msg selectedPks user =
    Html.div
        [ A.class "badge"
        , A.style [ "user-select" => "none" ]
        , E.onClick <| msgs.k <| msg (Maybe.withDefault [] selectedPks) user.pk
        ]
        [ Html.text user.email ]


userView : Messages msg -> (List Int -> Int -> Msg) -> Maybe (List Int) -> User -> Html msg
userView msgs toMsg maybeSelectedPks owner =
    let
        selectedPks =
            case maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks

        msg =
            toMsg selectedPks owner.pk

        id =
            case msg of
                UpdateSelectedOwner _ _ ->
                    "UpdateSelectedOwner"

                UpdateSelectedSubscriber _ _ ->
                    "UpdateSelectedSubscriber"

                _ ->
                    "_err"
    in
    Html.Keyed.node "div"
        [ A.class "item"
        , A.style [ "user-select" => "none" ]
        , E.onClick <| msgs.k <| msg
        , A.id <| "user" ++ id
        ]
        [ toString owner.pk => userViewHelper selectedPks owner ]


userViewHelper : List Int -> User -> Html msg
userViewHelper selectedPks owner =
    Html.div [ A.style [ "color" => "#000" ] ]
        [ selectedIcon selectedPks owner
        , Html.text owner.email
        ]


showArchiveNotice : List Keyword -> Maybe Keyword -> Model -> Bool
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


archiveNotice : Messages msg -> Bool -> List Keyword -> Maybe String -> Html msg
archiveNotice msgs show keywords name =
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
            Html.div [ A.class "alert" ]
                [ Html.p [] [ Html.text "There is already a Keyword that with that name in the archive" ]
                , Html.p [] [ Html.text "You can chose a different name." ]
                , Html.p []
                    [ Html.text "Or you can restore the keyword here: "
                    , msgs.spa matchedKeyword
                    ]
                ]


submitMsg : Messages msg -> Bool -> msg
submitMsg msgs showAN =
    case showAN of
        True ->
            msgs.noop

        False ->
            msgs.postForm
