module Pages.Forms.Contact exposing (Model, Msg, initialModel, update, view)

import Data exposing (Recipient)
import Forms.Model exposing (Field, FieldMeta, FormItem(FieldGroup, FormField), FormStatus, defaultFieldGroupConfig)
import Forms.View exposing (checkboxField, form, simpleTextField, submitButton)
import Html exposing (Html, div, p, text)
import Html.Attributes as A
import Pages.Error404 as E404
import Pages.Forms.Meta.Contact exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL


-- Model


type alias Model =
    { first_name : Maybe String
    , last_name : Maybe String
    , number : Maybe String
    , do_not_reply : Maybe Bool
    }


initialModel : Model
initialModel =
    { first_name = Nothing
    , last_name = Nothing
    , number = Nothing
    , do_not_reply = Nothing
    }



-- Update


type Msg
    = UpdateContactDoNotReplyField (Maybe Recipient)
    | UpdateContactFirstNameField String
    | UpdateContactLastNameField String
    | UpdateContactNumberField String


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateContactFirstNameField text ->
            { model | first_name = Just text }

        UpdateContactLastNameField text ->
            { model | last_name = Just text }

        UpdateContactDoNotReplyField maybeContact ->
            let
                b =
                    case model.do_not_reply of
                        Just curVal ->
                            not curVal

                        Nothing ->
                            case maybeContact of
                                Nothing ->
                                    False

                                Just c ->
                                    not c.do_not_reply
            in
            { model | do_not_reply = Just b }

        UpdateContactNumberField text ->
            { model | number = Just text }



-- View


type alias Props msg =
    { postForm : msg
    , c : Msg -> msg
    , noop : msg
    , spa : Maybe Int -> Html msg
    , defaultNumberPrefix : String
    }


view : Props msg -> Maybe (Html msg) -> Maybe Int -> RL.RemoteList Recipient -> Model -> FormStatus -> Html msg
view props maybeTable maybePk contacts_ model status =
    case maybePk of
        Nothing ->
            -- creating a new contact:
            creating props contacts_ model status

        Just pk ->
            -- trying to edit an existing contact:
            editing props maybeTable pk contacts_ model status


creating : Props msg -> RL.RemoteList Recipient -> Model -> FormStatus -> Html msg
creating props contacts model status =
    viewHelp props Nothing Nothing contacts model status


editing : Props msg -> Maybe (Html msg) -> Int -> RL.RemoteList Recipient -> Model -> FormStatus -> Html msg
editing props maybeTable pk contacts model status =
    let
        currentContact =
            contacts
                |> RL.toList
                |> List.filter (\x -> x.pk == pk)
                |> List.head
    in
    case currentContact of
        Just contact ->
            -- contact exists, show the form:
            viewHelp props maybeTable (Just contact) contacts model status

        Nothing ->
            -- contact does not exist:
            case contacts of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : Props msg -> Maybe (Html msg) -> Maybe Recipient -> RL.RemoteList Recipient -> Model -> FormStatus -> Html msg
viewHelp props maybeTable currentContact contacts_ model status =
    let
        contacts =
            RL.toList contacts_

        showAN =
            showArchiveNotice contacts currentContact model

        fields =
            [ FieldGroup { defaultFieldGroupConfig | sideBySide = True, header = Just "Name" }
                [ Field meta.first_name <| firstNameField props meta.first_name currentContact
                , Field meta.last_name <| lastNameField props meta.last_name currentContact
                ]
            , FormField <| Field meta.number <| numberField props meta.number props.defaultNumberPrefix currentContact
            , FormField <| Field meta.do_not_reply <| doNotReplyField props meta.do_not_reply currentContact
            ]
    in
    div []
        [ archiveNotice props showAN contacts model.number
        , form status fields (submitMsg props showAN) (submitButton currentContact showAN)
        , Maybe.withDefault (text "") maybeTable
        ]


firstNameField : Props msg -> FieldMeta -> Maybe Recipient -> List (Html msg)
firstNameField props meta_ maybeContact =
    simpleTextField
        meta_
        (Maybe.map .first_name maybeContact)
        (props.c << UpdateContactFirstNameField)


lastNameField : Props msg -> FieldMeta -> Maybe Recipient -> List (Html msg)
lastNameField props meta_ maybeContact =
    simpleTextField
        meta_
        (Maybe.map .last_name maybeContact)
        (props.c << UpdateContactLastNameField)


numberField : Props msg -> FieldMeta -> String -> Maybe Recipient -> List (Html msg)
numberField props meta_ defaultPrefix maybeContact =
    let
        num =
            case maybeContact of
                Nothing ->
                    Just defaultPrefix

                Just contact ->
                    contact.number
    in
    simpleTextField
        meta_
        num
        (props.c << UpdateContactNumberField)


doNotReplyField : Props msg -> FieldMeta -> Maybe Recipient -> List (Html msg)
doNotReplyField props meta_ maybeContact =
    checkboxField
        meta_
        maybeContact
        .do_not_reply
        (props.c << UpdateContactDoNotReplyField)


showArchiveNotice : List Recipient -> Maybe Recipient -> Model -> Bool
showArchiveNotice contacts maybeContact model =
    let
        originalNum =
            Maybe.map .number maybeContact
                |> Maybe.withDefault Nothing

        currentProposedNum =
            model.number

        archivedNums =
            contacts
                |> List.filter .is_archived
                |> List.map .number
    in
    case originalNum == currentProposedNum of
        True ->
            False

        False ->
            List.member currentProposedNum archivedNums


archiveNotice : Props msg -> Bool -> List Recipient -> Maybe String -> Html msg
archiveNotice props show contacts num =
    let
        matchedContact =
            contacts
                |> List.filter (\c -> c.number == num)
                |> List.head
                |> Maybe.map .pk
    in
    case show of
        False ->
            text ""

        True ->
            div [ A.class "alert" ]
                [ p [] [ text "There is already a Contact that with that number in the archive" ]
                , p []
                    [ text "Or you can restore the contact here: "
                    , props.spa matchedContact
                    ]
                ]


submitMsg : Props msg -> Bool -> msg
submitMsg props showAN =
    case showAN of
        True ->
            props.noop

        False ->
            props.postForm
