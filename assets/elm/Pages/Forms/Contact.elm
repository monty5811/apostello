module Pages.Forms.Contact exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (Recipient)
import DjangoSend
import FilteringTable as FT
import Form as F exposing (Field, FieldMeta, FormItem(FieldGroup, FormField), FormStatus(NoAction), checkboxField, defaultFieldGroupConfig, form, longTextField, simpleTextField, submitButton)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Error404 as E404
import Pages.Forms.Meta.Contact exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL
import Urls


--Model


type alias Model =
    { first_name : Maybe String
    , last_name : Maybe String
    , number : Maybe String
    , do_not_reply : Maybe Bool
    , never_contact : Maybe Bool
    , notes : Maybe String
    , formStatus : FormStatus
    , tableModel : FT.Model
    }


initialModel : Model
initialModel =
    { first_name = Nothing
    , last_name = Nothing
    , number = Nothing
    , do_not_reply = Nothing
    , never_contact = Nothing
    , notes = Nothing
    , formStatus = NoAction
    , tableModel = FT.initialModel
    }



-- Update


type Msg
    = PostForm Bool Bool
    | InputMsg InputMsg
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | TableMsg FT.Msg


type InputMsg
    = UpdateDoNotReplyField (Maybe Recipient)
    | UpdateNeverContactField (Maybe Recipient)
    | UpdateFirstNameField String
    | UpdateLastNameField String
    | UpdateNumberField String
    | UpdateNotesField String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , recipients : RL.RemoteList Recipient
    , maybePk : Maybe Int
    , canSeeContactNum : Bool
    , canSeeContactNotes : Bool
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

        TableMsg tableMsg ->
            F.UpdateResp
                { model | tableModel = FT.update tableMsg model.tableModel }
                Cmd.none
                []
                Nothing

        PostForm canSeeContactNum canSeeContactNotes ->
            F.UpdateResp
                (F.setInProgress model)
                (postCmd
                    props.csrftoken
                    model
                    props.canSeeContactNum
                    props.canSeeContactNotes
                    (RL.filter (\x -> Just x.pk == props.maybePk) props.recipients
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


postCmd : DjangoSend.CSRFToken -> Model -> Bool -> Bool -> Maybe Recipient -> Cmd Msg
postCmd csrf model canSeeContactNum canSeeContactNotes maybeContact =
    let
        body =
            [ ( "first_name", Encode.string <| F.extractField .first_name model.first_name maybeContact )
            , ( "last_name", Encode.string <| F.extractField .last_name model.last_name maybeContact )
            , ( "do_not_reply", Encode.bool <| F.extractBool .do_not_reply model.do_not_reply maybeContact )
            , ( "never_contact", Encode.bool <| F.extractBool .never_contact model.never_contact maybeContact )
            ]
                |> F.addPk maybeContact
                |> addContactNumber model canSeeContactNum maybeContact
                |> addContactNotes model canSeeContactNotes maybeContact
    in
    DjangoSend.rawPost csrf (Urls.api_recipients Nothing) body
        |> Http.send ReceiveFormResp


addContactNumber : Model -> Bool -> Maybe Recipient -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addContactNumber model canSeeContactNum maybeContact body =
    if canSeeContactNum then
        ( "number", Encode.string <| F.extractField (Maybe.withDefault "" << .number) model.number maybeContact ) :: body
    else
        body


addContactNotes : Model -> Bool -> Maybe Recipient -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addContactNotes model canSeeContactNotes maybeContact body =
    if canSeeContactNotes then
        ( "notes", Encode.string <| F.extractField .notes model.notes maybeContact ) :: body
    else
        body



-- View


type alias Props msg =
    { postForm : msg
    , c : InputMsg -> msg
    , noop : msg
    , spa : Maybe Int -> Html msg
    , defaultNumberPrefix : String
    , canSeeContactNum : Bool
    , canSeeContactNotes : Bool
    }


view : Props msg -> Maybe (Html msg) -> Maybe Int -> RL.RemoteList Recipient -> Model -> Html msg
view props maybeTable maybePk contacts_ model =
    case maybePk of
        Nothing ->
            -- creating a new contact:
            creating props contacts_ model

        Just pk ->
            -- trying to edit an existing contact:
            editing props maybeTable pk contacts_ model


creating : Props msg -> RL.RemoteList Recipient -> Model -> Html msg
creating props contacts model =
    viewHelp props Nothing Nothing contacts model


editing : Props msg -> Maybe (Html msg) -> Int -> RL.RemoteList Recipient -> Model -> Html msg
editing props maybeTable pk contacts model =
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
            viewHelp props maybeTable (Just contact) contacts model

        Nothing ->
            -- contact does not exist:
            case contacts of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : Props msg -> Maybe (Html msg) -> Maybe Recipient -> RL.RemoteList Recipient -> Model -> Html msg
viewHelp props maybeTable currentContact contacts_ model =
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
        , form model.formStatus fields (submitMsg props showAN) (submitButton currentContact)
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
