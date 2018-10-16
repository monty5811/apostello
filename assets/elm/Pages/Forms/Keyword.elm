module Pages.Forms.Keyword exposing
    ( Messages
    , Model
    , Msg(..)
    , init
    , initialModel
    , update
    , view
    )

import Css
import Data exposing (Keyword, RecipientGroup, User)
import Date
import DateTimePicker
import DjangoSend
import Encode
import FilteringTable exposing (textToRegex)
import Form as F exposing (defaultFieldGroupConfig)
import Future.String
import Helpers exposing (toggleSelectedPk, userFacingErrorMessage)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.Keyword exposing (meta)
import Regex
import RemoteList as RL
import Time
import Urls



-- Init


init : Model -> Cmd Msg
init model =
    case model.maybeId of
        Just _ ->
            Http.get (Urls.api_keywords model.maybeId) (Data.decodeListToItem Data.decodeKeyword)
                |> Http.send ReceiveInitialData

        Nothing ->
            initDatePickers model


initDatePickers : Model -> Cmd Msg
initDatePickers model =
    case F.getDirty model.form of
        Just dirtyState ->
            Cmd.batch
                [ DateTimePicker.initialCmd initActTime dirtyState.datePickerActState
                , DateTimePicker.initialCmd initDeactTime dirtyState.datePickerDeactState
                ]

        Nothing ->
            Cmd.none


initActTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initActTime state maybeDate =
    InputMsg <| UpdateActivateTime state maybeDate


initDeactTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initDeactTime state maybeDate =
    InputMsg <| UpdateDeactivateTime state maybeDate



-- Model


type alias Model =
    { form : F.Form Keyword DirtyState
    , maybeId : Maybe String
    }


initialModel : Maybe String -> Model
initialModel maybeId =
    case maybeId of
        Just _ ->
            { form = F.formLoading
            , maybeId = maybeId
            }

        Nothing ->
            { form = F.startCreating defaultKeyword initialDirtyState
            , maybeId = maybeId
            }


type alias DirtyState =
    { datePickerActState : DateTimePicker.State
    , datePickerDeactState : DateTimePicker.State
    , linkedGroupsFilter : Regex.Regex
    , ownersFilter : Regex.Regex
    , subscribersFilter : Regex.Regex
    }


initialDirtyState : DirtyState
initialDirtyState =
    { datePickerActState = DateTimePicker.initialState
    , datePickerDeactState = DateTimePicker.initialState
    , linkedGroupsFilter = Regex.regex ""
    , ownersFilter = Regex.regex ""
    , subscribersFilter = Regex.regex ""
    }


defaultKeyword : Keyword
defaultKeyword =
    { keyword = ""
    , pk = 0
    , description = ""
    , current_response = ""
    , is_live = False
    , num_replies = ""
    , num_archived_replies = ""
    , is_archived = False
    , disable_all_replies = False
    , custom_response = ""
    , custom_response_new_person = ""
    , deactivated_response = ""
    , too_early_response = ""
    , activate_time = Nothing
    , deactivate_time = Nothing
    , linked_groups = []
    , owners = []
    , subscribed_to_digest = []
    }



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | ReceiveInitialData (Result Http.Error (Maybe Keyword))


type InputMsg
    = UpdateKeywordKeywordField String
    | UpdateKeywordDescField String
    | UpdateKeywordDisableRepliesField
    | UpdateKeywordCustRespField String
    | UpdateKeywordCustNewPersonRespField String
    | UpdateKeywordDeacRespField String
    | UpdateKeywordTooEarlyRespField String
    | UpdateActivateTime DateTimePicker.State (Maybe Date.Date)
    | UpdateDeactivateTime DateTimePicker.State (Maybe Date.Date)
    | UpdateKeywordLinkedGroupsFilter String
    | UpdateSelectedLinkedGroup Int
    | UpdateKeywordOwnersFilter String
    | UpdateSelectedOwner Int
    | UpdateKeywordSubscribersFilter String
    | UpdateSelectedSubscriber Int


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , currentTime : Time.Time
    , keywords : RL.RemoteList Keyword
    , successPageUrl : String
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        ReceiveInitialData (Ok (Just keyword)) ->
            let
                newModel =
                    { model | form = F.startUpdating keyword initialDirtyState }
            in
            F.UpdateResp
                newModel
                (initDatePickers newModel)
                []
                Nothing

        ReceiveInitialData (Ok Nothing) ->
            F.UpdateResp
                { model | form = F.to404 }
                Cmd.none
                []
                Nothing

        ReceiveInitialData (Err err) ->
            F.UpdateResp
                { model | form = F.toError <| userFacingErrorMessage err }
                Cmd.none
                []
                Nothing

        InputMsg inputMsg ->
            F.UpdateResp
                { model | form = F.updateField (updateInput inputMsg) model.form }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postFormCmd props.csrftoken model)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> Keyword -> DirtyState -> ( Keyword, DirtyState )
updateInput msg model dirty =
    case msg of
        UpdateKeywordKeywordField text ->
            ( { model | keyword = text }, dirty )

        UpdateKeywordDescField text ->
            ( { model | description = text }, dirty )

        UpdateKeywordDisableRepliesField ->
            ( { model | disable_all_replies = not model.disable_all_replies }, dirty )

        UpdateKeywordCustRespField text ->
            ( { model | custom_response = text }, dirty )

        UpdateKeywordCustNewPersonRespField text ->
            ( { model | custom_response_new_person = text }, dirty )

        UpdateKeywordDeacRespField text ->
            ( { model | deactivated_response = text }, dirty )

        UpdateKeywordTooEarlyRespField text ->
            ( { model | too_early_response = text }, dirty )

        UpdateActivateTime state maybeDate ->
            case maybeDate of
                Nothing ->
                    ( model, { dirty | datePickerActState = state } )

                Just date ->
                    ( { model | activate_time = Just date }, { dirty | datePickerActState = state } )

        UpdateDeactivateTime state maybeDate ->
            ( { model | deactivate_time = maybeDate }, { dirty | datePickerDeactState = state } )

        UpdateKeywordLinkedGroupsFilter text ->
            ( model, { dirty | linkedGroupsFilter = textToRegex text } )

        UpdateSelectedLinkedGroup pk ->
            ( { model | linked_groups = toggleSelectedPk pk model.linked_groups }, dirty )

        UpdateKeywordOwnersFilter text ->
            ( model, { dirty | ownersFilter = textToRegex text } )

        UpdateSelectedOwner pk ->
            ( { model | owners = toggleSelectedPk pk model.owners }, dirty )

        UpdateKeywordSubscribersFilter text ->
            ( model, { dirty | subscribersFilter = textToRegex text } )

        UpdateSelectedSubscriber pk ->
            ( { model | subscribed_to_digest = toggleSelectedPk pk model.subscribed_to_digest }, dirty )


postFormCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postFormCmd csrf { form } =
    case F.getCurrent form of
        Just model ->
            let
                body =
                    [ ( "keyword", Encode.string model.keyword )
                    , ( "description", Encode.string model.description )
                    , ( "disable_all_replies", Encode.bool model.disable_all_replies )
                    , ( "custom_response", Encode.string model.custom_response )
                    , ( "custom_response_new_person", Encode.string model.custom_response_new_person )
                    , ( "deactivated_response", Encode.string model.deactivated_response )
                    , ( "too_early_response", Encode.string model.too_early_response )
                    , ( "activate_time", Encode.encodeMaybeDate model.activate_time )
                    , ( "deactivate_time", Encode.encodeMaybeDate model.deactivate_time )
                    , ( "linked_groups", Encode.list <| List.map Encode.int model.linked_groups )
                    , ( "owners", Encode.list <| List.map Encode.int model.owners )
                    , ( "subscribed_to_digest", Encode.list <| List.map Encode.int model.subscribed_to_digest )
                    ]
                        |> addPk model
            in
            DjangoSend.rawPost csrf (Urls.api_keywords Nothing) body
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none


addPk : Keyword -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addPk { pk } data =
    if pk == 0 then
        data

    else
        [ ( "pk", Encode.int pk ) ] ++ data



-- View


type alias Messages msg =
    { postForm : msg
    , inputChange : InputMsg -> msg
    , noop : msg
    , spa : Maybe String -> Html msg
    }


view : Messages msg -> RL.RemoteList Keyword -> RL.RemoteList RecipientGroup -> RL.RemoteList User -> Model -> Html msg
view msgs keywords groups users model =
    let
        keywords_ =
            RL.toList keywords

        showAN =
            F.showArchiveNotice keywords_ .keyword model.form
    in
    Html.div []
        [ archiveNotice msgs showAN keywords_ <| Maybe.map .keyword <| F.getCurrent model.form
        , F.form
            model.form
            (fieldsHelp msgs users groups)
            (submitMsg msgs showAN)
            F.submitButton
        ]


fieldsHelp : Messages msg -> RL.RemoteList User -> RL.RemoteList RecipientGroup -> F.Item Keyword -> DirtyState -> List (F.FormItem msg)
fieldsHelp msgs users groups item dirty =
    [ F.FormField <| F.Field meta.keyword (keywordField msgs item)
    , F.FormField <| F.Field meta.description (descField msgs item)
    , F.FormField <| F.Field meta.disable_all_replies (disableRepliesField msgs item)
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "Replies" }
        [ F.Field meta.custom_response (customRespField msgs item)
        , F.Field meta.custom_response_new_person (customRespNewPersonField msgs item)
        , F.Field meta.deactivated_response (deactivatedRespField msgs item)
        , F.Field meta.too_early_response (tooEarlyRespField msgs item)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "Scheduling" }
        [ F.Field meta.activate_time (activateTimeField msgs dirty item)
        , F.Field meta.deactivate_time (deactivateTimeField msgs dirty item)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "Other Settings" }
        [ F.Field meta.linked_groups (linkedGroupsField msgs groups dirty item)
        , F.Field meta.owners (ownersField msgs users dirty item)
        , F.Field meta.subscribed_to_digest (digestField msgs users dirty item)
        ]
    ]


keywordField : Messages msg -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
keywordField msgs item =
    F.simpleTextField
        { getValue = .keyword, item = item, onInput = msgs.inputChange << UpdateKeywordKeywordField }


descField : Messages msg -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
descField msgs item =
    F.simpleTextField
        { getValue = .description, item = item, onInput = msgs.inputChange << UpdateKeywordDescField }


disableRepliesField : Messages msg -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
disableRepliesField msgs item =
    F.checkboxField
        .disable_all_replies
        item
        (msgs.inputChange UpdateKeywordDisableRepliesField)


customRespField : Messages msg -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
customRespField msgs item =
    F.longTextField 3
        { getValue = .custom_response, item = item, onInput = msgs.inputChange << UpdateKeywordCustRespField }


customRespNewPersonField : Messages msg -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
customRespNewPersonField msgs item =
    F.longTextField 3
        { getValue = .custom_response_new_person, item = item, onInput = msgs.inputChange << UpdateKeywordCustNewPersonRespField }


deactivatedRespField : Messages msg -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
deactivatedRespField msgs item =
    F.longTextField 3
        { getValue = .deactivated_response, item = item, onInput = msgs.inputChange << UpdateKeywordDeacRespField }


tooEarlyRespField : Messages msg -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
tooEarlyRespField msgs item =
    F.longTextField 3
        { getValue = .too_early_response, item = item, onInput = msgs.inputChange << UpdateKeywordTooEarlyRespField }


activateTimeField : Messages msg -> DirtyState -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
activateTimeField msgs dirty item =
    F.dateTimeField
        (updateActTime msgs)
        dirty.datePickerActState
        .activate_time
        item


updateActTime : Messages msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateActTime msgs state maybeDate =
    msgs.inputChange <| UpdateActivateTime state maybeDate


deactivateTimeField : Messages msg -> DirtyState -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
deactivateTimeField msgs dirty item =
    F.dateTimeField
        (updateDeactTime msgs)
        dirty.datePickerDeactState
        .deactivate_time
        item


updateDeactTime : Messages msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateDeactTime msgs state maybeDate =
    msgs.inputChange <| UpdateDeactivateTime state maybeDate


linkedGroupsField : Messages msg -> RL.RemoteList RecipientGroup -> DirtyState -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
linkedGroupsField msgs groups dirty item =
    F.multiSelectField
        { items = groups
        , getPks = .linked_groups
        , item = item
        , filter = dirty.linkedGroupsFilter
        , filterMsg = msgs.inputChange << UpdateKeywordLinkedGroupsFilter
        , itemView = groupView msgs
        , selectedView = groupLabelView msgs
        }


groupLabelView : Messages msg -> List Int -> RecipientGroup -> Html msg
groupLabelView msgs maybePks group =
    F.multiSelectItemLabelHelper
        .name
        (msgs.inputChange <| UpdateSelectedLinkedGroup group.pk)
        group


groupView : Messages msg -> List Int -> RecipientGroup -> Html msg
groupView msgs selectedPks group =
    F.multiSelectItemHelper
        { itemToStr = .name
        , selectedPks = selectedPks
        , itemToKey = .pk >> Future.String.fromInt
        , toggleMsg = msgs.inputChange << UpdateSelectedLinkedGroup
        , itemToId = .pk >> Future.String.fromInt >> (++) "linkedGroup"
        }
        group


ownersField : Messages msg -> RL.RemoteList User -> DirtyState -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
ownersField msgs users dirty item =
    F.multiSelectField
        { items = users
        , getPks = .owners
        , item = item
        , filter = dirty.ownersFilter
        , filterMsg = msgs.inputChange << UpdateKeywordOwnersFilter
        , itemView = ownerUserView msgs
        , selectedView = userLabelView msgs UpdateSelectedOwner
        }


digestField : Messages msg -> RL.RemoteList User -> DirtyState -> F.Item Keyword -> F.FieldMeta -> List (Html msg)
digestField msgs users dirty item =
    F.multiSelectField
        { items = users
        , getPks = .subscribed_to_digest
        , item = item
        , filter = dirty.subscribersFilter
        , filterMsg = msgs.inputChange << UpdateKeywordSubscribersFilter
        , itemView = digestUserView msgs
        , selectedView = userLabelView msgs UpdateSelectedSubscriber
        }


userLabelView : Messages msg -> (Int -> InputMsg) -> List Int -> User -> Html msg
userLabelView msgs msg selectedPks user =
    F.multiSelectItemLabelHelper
        .email
        (msgs.inputChange <| msg user.pk)
        user


digestUserView : Messages msg -> List Int -> User -> Html msg
digestUserView msgs selectedPks user =
    F.multiSelectItemHelper
        { itemToStr = .email
        , selectedPks = selectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = msgs.inputChange << UpdateSelectedSubscriber
        , itemToId = .pk >> toString >> (++) "userUpdateSelectedSubscriber"
        }
        user


ownerUserView : Messages msg -> List Int -> User -> Html msg
ownerUserView msgs selectedPks owner =
    F.multiSelectItemHelper
        { itemToStr = .email
        , selectedPks = selectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = msgs.inputChange << UpdateSelectedOwner
        , itemToId = .pk >> toString >> (++) "userUpdateSelectedOwner"
        }
        owner


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
            Html.div [ Css.alert, Css.alert_info ]
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
