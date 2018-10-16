module Pages.Forms.Contact exposing (Model, Msg(..), init, initialModel, update, view)

import Css
import Data exposing (Recipient)
import DjangoSend
import Encode exposing (encodeMaybe)
import FilteringTable as FT
import Form as F exposing (defaultFieldGroupConfig)
import Helpers exposing (userFacingErrorMessage)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.Contact exposing (meta)
import RemoteList as RL
import Urls


init : Model -> Cmd Msg
init model =
    case model.maybePk of
        Just _ ->
            Http.get (Urls.api_recipients model.maybePk) (Data.decodeListToItem Data.decodeRecipient)
                |> Http.send ReceiveInitialData

        Nothing ->
            Cmd.none



--Model


type alias Model =
    { form : F.Form Recipient ()
    , maybePk : Maybe Int
    , tableModel : FT.Model
    }


initialModel : Maybe Int -> Model
initialModel maybePk =
    case maybePk of
        Just _ ->
            { form = F.formLoading
            , maybePk = maybePk
            , tableModel = FT.initialModel
            }

        Nothing ->
            { form = F.startCreating defaultContact ()
            , maybePk = maybePk
            , tableModel = FT.initialModel
            }



-- Update


type Msg
    = PostForm Bool Bool
    | InputMsg InputMsg
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | ReceiveInitialData (Result Http.Error (Maybe Recipient))
    | TableMsg FT.Msg


type InputMsg
    = UpdateDoNotReplyField
    | UpdateNeverContactField
    | UpdateFirstNameField String
    | UpdateLastNameField String
    | UpdateNumberField String
    | UpdateNotesField String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , recipients : RL.RemoteList Recipient
    , canSeeContactNum : Bool
    , canSeeContactNotes : Bool
    , successPageUrl : String
    }


defaultContact : Recipient
defaultContact =
    { first_name = ""
    , last_name = ""
    , full_name = ""
    , is_archived = False
    , is_blocking = False
    , last_sms = Nothing
    , never_contact = False
    , notes = ""
    , number = Nothing
    , pk = 0
    , do_not_reply = False
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        ReceiveInitialData (Ok (Just contact)) ->
            F.UpdateResp
                { model | form = F.startUpdating contact () }
                Cmd.none
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
                )
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> Recipient -> () -> ( Recipient, () )
updateInput msg model _ =
    ( updateInputHelp msg model, () )


updateInputHelp : InputMsg -> Recipient -> Recipient
updateInputHelp msg model =
    case msg of
        UpdateFirstNameField text ->
            { model | first_name = text }

        UpdateLastNameField text ->
            { model | last_name = text }

        UpdateDoNotReplyField ->
            { model | do_not_reply = not model.do_not_reply }

        UpdateNeverContactField ->
            { model | never_contact = not model.never_contact }

        UpdateNumberField text ->
            { model | number = Just text }

        UpdateNotesField text ->
            { model | notes = text }


postCmd : DjangoSend.CSRFToken -> Model -> Bool -> Bool -> Cmd Msg
postCmd csrf { maybePk, form } canSeeContactNum canSeeContactNotes =
    case F.getCurrent form of
        Just contact ->
            let
                body =
                    [ ( "first_name", Encode.string <| contact.first_name )
                    , ( "last_name", Encode.string <| contact.last_name )
                    , ( "do_not_reply", Encode.bool <| contact.do_not_reply )
                    , ( "never_contact", Encode.bool <| contact.never_contact )
                    ]
                        |> F.addPk maybePk
                        |> addContactNumber contact canSeeContactNum
                        |> addContactNotes contact canSeeContactNotes
            in
            DjangoSend.rawPost csrf (Urls.api_recipients Nothing) body
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none


addContactNumber : Recipient -> Bool -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addContactNumber contact canSeeContactNum body =
    if canSeeContactNum then
        ( "number", encodeMaybe Encode.string contact.number ) :: body

    else
        body


addContactNotes : Recipient -> Bool -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addContactNotes contact canSeeContactNotes body =
    if canSeeContactNotes then
        ( "notes", Encode.string contact.notes ) :: body

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


view : Props msg -> Maybe (Html msg) -> RL.RemoteList Recipient -> Model -> Html msg
view props maybeTable contacts model =
    let
        showAN =
            F.showArchiveNotice
                (RL.toList contacts)
                .number
                model.form
    in
    Html.div []
        [ archiveNotice props
            showAN
            (RL.toList contacts)
            (Maybe.andThen .number (F.getCurrent model.form))
        , F.form
            model.form
            (fieldsHelp props)
            (submitMsg props showAN)
            F.submitButton
        , case maybeTable of
            Just table ->
                Html.div [ Css.mt_4, Css.max_w_md, Css.mx_auto ] [ table ]

            Nothing ->
                Html.text ""
        ]


fieldsHelp : Props msg -> F.Item Recipient -> () -> List (F.FormItem msg)
fieldsHelp props item _ =
    [ Just <|
        F.FieldGroup { defaultFieldGroupConfig | sideBySide = Just 2, header = Nothing }
            [ F.Field meta.first_name <| firstNameField props item
            , F.Field meta.last_name <| lastNameField props item
            ]
    , if props.canSeeContactNum then
        Just <| F.FormField <| F.Field meta.number <| numberField props item

      else
        Nothing
    , Just <| F.FormField <| F.Field meta.do_not_reply <| doNotReplyField props item
    , Just <| F.FormField <| F.Field meta.never_contact <| neverContactField props item
    , if props.canSeeContactNotes then
        Just <| F.FormField <| F.Field meta.notes <| notesField props item

      else
        Nothing
    ]
        |> List.filterMap identity


firstNameField : Props msg -> F.Item Recipient -> (F.FieldMeta -> List (Html msg))
firstNameField props item =
    F.simpleTextField
        { getValue = .first_name
        , item = item
        , onInput = props.c << UpdateFirstNameField
        }


lastNameField : Props msg -> F.Item Recipient -> (F.FieldMeta -> List (Html msg))
lastNameField props item =
    F.simpleTextField
        { getValue = .last_name
        , item = item
        , onInput = props.c << UpdateLastNameField
        }


numberField : Props msg -> F.Item Recipient -> (F.FieldMeta -> List (Html msg))
numberField props item =
    let
        defaultNum =
            case F.itemGetOriginal item of
                Nothing ->
                    props.defaultNumberPrefix

                Just defaultContact ->
                    Maybe.withDefault "" defaultContact.number
    in
    F.simpleTextField
        { getValue = .number >> Maybe.withDefault defaultNum
        , item = item
        , onInput = props.c << UpdateNumberField
        }


notesField : Props msg -> F.Item Recipient -> (F.FieldMeta -> List (Html msg))
notesField props item =
    F.longTextField
        5
        { getValue = .notes
        , item = item
        , onInput = props.c << UpdateNotesField
        }


doNotReplyField : Props msg -> F.Item Recipient -> (F.FieldMeta -> List (Html msg))
doNotReplyField props item =
    F.checkboxField
        .do_not_reply
        item
        (props.c UpdateDoNotReplyField)


neverContactField : Props msg -> F.Item Recipient -> (F.FieldMeta -> List (Html msg))
neverContactField props item =
    F.checkboxField
        .never_contact
        item
        (props.c UpdateNeverContactField)


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
            Html.div [ Css.alert, Css.alert_info ]
                [ Html.p [] [ Html.text "There is already a Contact that with that number in the archive" ]
                , Html.p []
                    [ Html.text "You can restore the contact here: "
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
