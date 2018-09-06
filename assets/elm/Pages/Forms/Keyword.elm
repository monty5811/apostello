module Pages.Forms.Keyword exposing (Messages, Model, Msg(..), activateTimeField, archiveNotice, creating, customRespField, customRespNewPersonField, deactivateTimeField, deactivatedRespField, descField, digestField, digestUserView, disableRepliesField, editing, groupLabelView, groupView, init, initActTime, initDeactTime, initialModel, keywordField, linkedGroupsField, ownerUserView, ownersField, showArchiveNotice, submitMsg, tooEarlyRespField, update, updateActTime, updateDeactTime, userLabelView, view, viewHelp)

import Data exposing (Keyword, RecipientGroup, User)
import Date
import DateTimePicker
import DjangoSend
import Encode
import FilteringTable exposing (textToRegex)
import Form as F exposing (..)
import Helpers exposing (toggleSelectedPk)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Error404 as E404
import Pages.Forms.Meta.Keyword exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Time
import Urls


-- Init


init : Model -> Cmd Msg
init model =
    Cmd.batch
        [ DateTimePicker.initialCmd initActTime model.datePickerActState
        , DateTimePicker.initialCmd initDeactTime model.datePickerDeactState
        ]


initActTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initActTime state maybeDate =
    InputMsg <| UpdateActivateTime state maybeDate


initDeactTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initDeactTime state maybeDate =
    InputMsg <| UpdateDeactivateTime state maybeDate



-- Model


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
    , formStatus : FormStatus
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
    , formStatus = NoAction
    }


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type InputMsg
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


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , currentTime : Time.Time
    , keywords : RL.RemoteList Keyword
    , maybeKeywordName : Maybe String
    , successPageUrl : String
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        InputMsg inputMsg ->
            F.UpdateResp
                (updateInput inputMsg model)
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postFormCmd
                    props.csrftoken
                    props.currentTime
                    model
                    (RL.filter (\x -> Just x.keyword == props.maybeKeywordName) props.keywords
                        |> RL.toList
                        |> List.head
                    )
                )
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> Model -> Model
updateInput msg model =
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


postFormCmd : DjangoSend.CSRFToken -> Time.Time -> Model -> Maybe Keyword -> Cmd Msg
postFormCmd csrf now model maybeKeyword =
    let
        body =
            [ ( "keyword", Encode.string <| F.extractField .keyword model.keyword maybeKeyword )
            , ( "description", Encode.string <| F.extractField .description model.description maybeKeyword )
            , ( "disable_all_replies", Encode.bool <| F.extractBool .disable_all_replies model.disable_all_replies maybeKeyword )
            , ( "custom_response", Encode.string <| F.extractField .custom_response model.custom_response maybeKeyword )
            , ( "custom_response_new_person", Encode.string <| F.extractField .custom_response_new_person model.custom_response_new_person maybeKeyword )
            , ( "deactivated_response", Encode.string <| F.extractField .deactivated_response model.deactivated_response maybeKeyword )
            , ( "too_early_response", Encode.string <| F.extractField .too_early_response model.too_early_response maybeKeyword )
            , ( "activate_time", Encode.encodeDate <| extractDate now .activate_time model.activate_time maybeKeyword )
            , ( "deactivate_time", Encode.encodeMaybeDate <| extractMaybeDate .deactivate_time model.deactivate_time maybeKeyword )
            , ( "linked_groups", Encode.list <| List.map Encode.int <| extractPks .linked_groups model.linked_groups maybeKeyword )
            , ( "owners", Encode.list <| List.map Encode.int <| extractPks .owners model.owners maybeKeyword )
            , ( "subscribed_to_digest", Encode.list <| List.map Encode.int <| extractPks .subscribed_to_digest model.subscribers maybeKeyword )
            ]
                |> F.addPk maybeKeyword
    in
    DjangoSend.rawPost csrf (Urls.api_keywords Nothing) body
        |> Http.send ReceiveFormResp


extractPks : (Keyword -> List Int) -> Maybe (List Int) -> Maybe Keyword -> List Int
extractPks fn field maybeKeyword =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to []
            Maybe.map fn maybeKeyword
                |> Maybe.withDefault []

        Just pks ->
            pks


extractDate : Time.Time -> (Keyword -> Date.Date) -> Maybe Date.Date -> Maybe Keyword -> Date.Date
extractDate now fn field maybeKeyword =
    case field of
        Nothing ->
            Maybe.map fn maybeKeyword
                |> Maybe.withDefault (Date.fromTime now)

        Just d ->
            d


extractMaybeDate : (Keyword -> Maybe Date.Date) -> Maybe Date.Date -> Maybe Keyword -> Maybe Date.Date
extractMaybeDate fn field maybeKeyword =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to ""
            Maybe.andThen fn maybeKeyword

        Just s ->
            Just s



-- View


type alias Messages msg =
    { postForm : msg
    , inputChange : InputMsg -> msg
    , noop : msg
    , spa : Maybe String -> Html msg
    }


view : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> Maybe String -> Model -> Html msg
view msgs keywords groups users maybeK model =
    case maybeK of
        Nothing ->
            -- creating a new keyword:
            creating msgs keywords groups users model

        Just k ->
            -- trying to edit an existing keyword:
            editing msgs keywords groups users k model


creating : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> Model -> Html msg
creating msgs keywords groups users model =
    viewHelp msgs keywords groups users Nothing model


editing : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> String -> Model -> Html msg
editing msgs keywords groups users keyword model =
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
            viewHelp msgs keywords groups users (Just k) model

        Nothing ->
            -- keyword does not exist:
            case keywords of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> Maybe Keyword -> Model -> Html msg
viewHelp msgs keywords_ groups users currentKeyword model =
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
        , form model.formStatus fields (submitMsg msgs showAN) (submitButton currentKeyword)
        ]


keywordField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
keywordField msgs maybeKeyword =
    simpleTextField
        (Maybe.map .keyword maybeKeyword)
        (msgs.inputChange << UpdateKeywordKeywordField)


descField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
descField msgs maybeKeyword =
    simpleTextField
        (Maybe.map .description maybeKeyword)
        (msgs.inputChange << UpdateKeywordDescField)


disableRepliesField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
disableRepliesField msgs maybeKeyword =
    checkboxField
        maybeKeyword
        .disable_all_replies
        (msgs.inputChange << UpdateKeywordDisableRepliesField)


customRespField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
customRespField msgs maybeKeyword =
    simpleTextField (Maybe.map .custom_response maybeKeyword) (msgs.inputChange << UpdateKeywordCustRespField)


customRespNewPersonField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
customRespNewPersonField msgs maybeKeyword =
    simpleTextField (Maybe.map .custom_response_new_person maybeKeyword) (msgs.inputChange << UpdateKeywordCustNewPersonRespField)


deactivatedRespField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
deactivatedRespField msgs maybeKeyword =
    simpleTextField (Maybe.map .deactivated_response maybeKeyword) (msgs.inputChange << UpdateKeywordDeacRespField)


tooEarlyRespField : Messages msg -> Maybe Keyword -> FieldMeta -> List (Html msg)
tooEarlyRespField msgs maybeKeyword =
    simpleTextField (Maybe.map .too_early_response maybeKeyword) (msgs.inputChange << UpdateKeywordTooEarlyRespField)


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
    msgs.inputChange <| UpdateActivateTime state maybeDate


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
    msgs.inputChange <| UpdateDeactivateTime state maybeDate


linkedGroupsField : Messages msg -> Model -> RL.RemoteList RecipientGroup -> Maybe Keyword -> FieldMeta -> List (Html msg)
linkedGroupsField msgs model groups maybeKeyword =
    multiSelectField
        (MultiSelectField
            groups
            model.linked_groups
            (Maybe.map .linked_groups maybeKeyword)
            model.linkedGroupsFilter
            (msgs.inputChange << UpdateKeywordLinkedGroupsFilter)
            (groupView msgs)
            (groupLabelView msgs)
        )


groupLabelView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupLabelView msgs maybePks group =
    multiSelectItemLabelHelper
        .name
        (msgs.inputChange <| UpdateSelectedLinkedGroup (Maybe.withDefault [] maybePks) group.pk)
        group


groupView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupView msgs maybeSelectedPks group =
    F.multiSelectItemHelper
        { itemToStr = .name
        , maybeSelectedPks = maybeSelectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = msgs.inputChange << UpdateSelectedLinkedGroup (Maybe.withDefault [] maybeSelectedPks)
        , itemToId = .pk >> toString >> (++) "linkedGroup"
        }
        group


ownersField : Messages msg -> Model -> RL.RemoteList User -> Maybe Keyword -> FieldMeta -> List (Html msg)
ownersField msgs model users maybeKeyword =
    multiSelectField
        (MultiSelectField
            users
            model.owners
            (Maybe.map .owners maybeKeyword)
            model.ownersFilter
            (msgs.inputChange << UpdateKeywordOwnersFilter)
            (ownerUserView msgs)
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
            (msgs.inputChange << UpdateKeywordSubscribersFilter)
            (digestUserView msgs)
            (userLabelView msgs UpdateSelectedSubscriber)
        )


userLabelView : Messages msg -> (List Int -> Int -> InputMsg) -> Maybe (List Int) -> User -> Html msg
userLabelView msgs msg selectedPks user =
    multiSelectItemLabelHelper
        .email
        (msgs.inputChange <| msg (Maybe.withDefault [] selectedPks) user.pk)
        user


digestUserView : Messages msg -> Maybe (List Int) -> User -> Html msg
digestUserView msgs maybeSelectedPks user =
    F.multiSelectItemHelper
        { itemToStr = .email
        , maybeSelectedPks = maybeSelectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = msgs.inputChange << UpdateSelectedSubscriber (Maybe.withDefault [] maybeSelectedPks)
        , itemToId = .pk >> toString >> (++) "userUpdateSelectedSubscriber"
        }
        user


ownerUserView : Messages msg -> Maybe (List Int) -> User -> Html msg
ownerUserView msgs maybeSelectedPks owner =
    F.multiSelectItemHelper
        { itemToStr = .email
        , maybeSelectedPks = maybeSelectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = msgs.inputChange << UpdateSelectedOwner (Maybe.withDefault [] maybeSelectedPks)
        , itemToId = .pk >> toString >> (++) "userUpdateSelectedOwner"
        }
        owner


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
            Html.div []
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
