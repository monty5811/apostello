module Pages.Forms.Contact exposing (Model, Msg, initialModel, update, view)

import Css
import Data exposing (Recipient)
import Forms.Model exposing (Field, FieldMeta, FormItem(FieldGroup, FormField), FormStatus, defaultFieldGroupConfig)
import Forms.View exposing (checkboxField, form, longTextField, simpleTextField, submitButton)
import Html exposing (Html)
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
    , never_contact : Maybe Bool
    , notes : Maybe String
    }


initialModel : Model
initialModel =
    { first_name = Nothing
    , last_name = Nothing
    , number = Nothing
    , do_not_reply = Nothing
    , never_contact = Nothing
    , notes = Nothing
    }



-- Update


type Msg
    = UpdateDoNotReplyField (Maybe Recipient)
    | UpdateNeverContactField (Maybe Recipient)
    | UpdateFirstNameField String
    | UpdateLastNameField String
    | UpdateNumberField String
    | UpdateNotesField String


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateFirstNameField text ->
            { model | first_name = Just text }

        UpdateLastNameField text ->
            { model | last_name = Just text }

        UpdateDoNotReplyField maybeContact ->
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

        UpdateNeverContactField maybeContact ->
            let
                b =
                    case model.never_contact of
                        Just curVal ->
                            not curVal

                        Nothing ->
                            case maybeContact of
                                Nothing ->
                                    False

                                Just c ->
                                    not c.never_contact
            in
            { model | never_contact = Just b }

        UpdateNumberField text ->
            { model | number = Just text }

        UpdateNotesField text ->
            { model | notes = Just text }



-- View


type alias Props msg =
    { postForm : msg
    , c : Msg -> msg
    , noop : msg
    , spa : Maybe Int -> Html msg
    , defaultNumberPrefix : String
    , canSeeContactNum : Bool
    , canSeeContactNotes : Bool
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
            [ Just <|
                FieldGroup { defaultFieldGroupConfig | sideBySide = Just 2, header = Nothing }
                    [ Field meta.first_name <| firstNameField props currentContact
                    , Field meta.last_name <| lastNameField props currentContact
                    ]
            , if props.canSeeContactNum then
                Just <| FormField <| Field meta.number <| numberField props props.defaultNumberPrefix currentContact
              else
                Nothing
            , Just <| FormField <| Field meta.do_not_reply <| doNotReplyField props currentContact
            , Just <| FormField <| Field meta.never_contact <| neverContactField props currentContact
            , if props.canSeeContactNotes then
                Just <| FormField <| Field meta.notes <| notesField props currentContact
              else
                Nothing
            ]
                |> List.filterMap identity
    in
    Html.div []
        [ archiveNotice props showAN contacts model.number
        , form status fields (submitMsg props showAN) (submitButton currentContact)
        , case maybeTable of
            Just table ->
                Html.div [ Css.mt_4, Css.max_w_md, Css.mx_auto ] [ table ]

            Nothing ->
                Html.text ""
        ]


firstNameField : Props msg -> Maybe Recipient -> (FieldMeta -> List (Html msg))
firstNameField props maybeContact =
    simpleTextField
        (Maybe.map .first_name maybeContact)
        (props.c << UpdateFirstNameField)


lastNameField : Props msg -> Maybe Recipient -> (FieldMeta -> List (Html msg))
lastNameField props maybeContact =
    simpleTextField
        (Maybe.map .last_name maybeContact)
        (props.c << UpdateLastNameField)


numberField : Props msg -> String -> Maybe Recipient -> (FieldMeta -> List (Html msg))
numberField props defaultPrefix maybeContact =
    let
        num =
            case maybeContact of
                Nothing ->
                    Just defaultPrefix

                Just contact ->
                    contact.number
    in
    simpleTextField
        num
        (props.c << UpdateNumberField)


notesField : Props msg -> Maybe Recipient -> (FieldMeta -> List (Html msg))
notesField props maybeContact =
    longTextField
        5
        (Maybe.map .notes maybeContact)
        (props.c << UpdateNotesField)


doNotReplyField : Props msg -> Maybe Recipient -> (FieldMeta -> List (Html msg))
doNotReplyField props maybeContact =
    checkboxField
        maybeContact
        .do_not_reply
        (props.c << UpdateDoNotReplyField)


neverContactField : Props msg -> Maybe Recipient -> (FieldMeta -> List (Html msg))
neverContactField props maybeContact =
    checkboxField
        maybeContact
        .never_contact
        (props.c << UpdateNeverContactField)


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
            Html.text ""

        True ->
            Html.div []
                [ Html.p [] [ Html.text "There is already a Contact that with that number in the archive" ]
                , Html.p []
                    [ Html.text "Or you can restore the contact here: "
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
