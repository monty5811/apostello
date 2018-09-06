module Pages.Forms.DefaultResponses exposing (Model, Msg(..), decodeFModel, init, initialModel, update, view)

import DjangoSend
import Form as F exposing (Field, FieldMeta, FormItem(FieldGroup), FormStatus(NoAction), defaultFieldGroupConfig)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Pages.Forms.Meta.DefaultResponses exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Urls


init : Cmd Msg
init =
    Http.get Urls.api_default_responses decodeFModel
        |> Http.send ReceiveInitialData


type alias Model =
    { fModel : Maybe FModel
    , formStatus : FormStatus
    }


initialModel : Model
initialModel =
    { fModel = Nothing
    , formStatus = NoAction
    }


type alias FModel =
    { keyword_no_match : String
    , default_no_keyword_auto_reply : String
    , default_no_keyword_not_live : String
    , start_reply : String
    , auto_name_request : String
    , name_update_reply : String
    , name_failure_reply : String
    }


decodeFModel : Decode.Decoder FModel
decodeFModel =
    decode FModel
        |> required "keyword_no_match" Decode.string
        |> required "default_no_keyword_auto_reply" Decode.string
        |> required "default_no_keyword_not_live" Decode.string
        |> required "start_reply" Decode.string
        |> required "auto_name_request" Decode.string
        |> required "name_update_reply" Decode.string
        |> required "name_failure_reply" Decode.string



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | ReceiveInitialData (Result Http.Error FModel)


type InputMsg
    = UpdateKeywordNoMatch String
    | UpdateNoKeywordAutoReply String
    | UpdateDefaultNoKeywordNotLive String
    | UpdateStartReply String
    | UpdateAutoName String
    | UpdateNameUpdateReply String
    | UpdateNameFailReply String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        ReceiveInitialData (Ok initialModel) ->
            F.UpdateResp
                { model | fModel = Just initialModel }
                Cmd.none
                []
                Nothing

        ReceiveInitialData (Err _) ->
            F.UpdateResp
                model
                Cmd.none
                []
                Nothing

        InputMsg inputMsg ->
            F.UpdateResp
                { model | fModel = Maybe.map (updateInput inputMsg) model.fModel }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postCmd props.csrftoken model.fModel)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> FModel -> FModel
updateInput msg model =
    case msg of
        UpdateKeywordNoMatch text ->
            { model | keyword_no_match = text }

        UpdateNoKeywordAutoReply text ->
            { model | default_no_keyword_auto_reply = text }

        UpdateDefaultNoKeywordNotLive text ->
            { model | default_no_keyword_not_live = text }

        UpdateStartReply text ->
            { model | start_reply = text }

        UpdateAutoName text ->
            { model | auto_name_request = text }

        UpdateNameUpdateReply text ->
            { model | name_update_reply = text }

        UpdateNameFailReply text ->
            { model | name_failure_reply = text }


postCmd : DjangoSend.CSRFToken -> Maybe FModel -> Cmd Msg
postCmd csrf maybeModel =
    case maybeModel of
        Nothing ->
            Cmd.none

        Just model ->
            let
                body =
                    [ ( "keyword_no_match", Encode.string model.keyword_no_match )
                    , ( "default_no_keyword_auto_reply", Encode.string model.default_no_keyword_auto_reply )
                    , ( "default_no_keyword_not_live", Encode.string model.default_no_keyword_not_live )
                    , ( "start_reply", Encode.string model.start_reply )
                    , ( "auto_name_request", Encode.string model.auto_name_request )
                    , ( "name_update_reply", Encode.string model.name_update_reply )
                    , ( "name_failure_reply", Encode.string model.name_failure_reply )
                    ]
            in
            DjangoSend.rawPost csrf Urls.api_default_responses body
                |> Http.send ReceiveFormResp



-- View


type alias Messages msg =
    { form : InputMsg -> msg
    , postForm : msg
    }


view : Messages msg -> Model -> Html msg
view msgs { fModel, formStatus } =
    case fModel of
        Nothing ->
            loader

        Just model ->
            let
                fields =
                    [ FieldGroup { defaultFieldGroupConfig | header = Just "Keyword" }
                        [ Field meta.keyword_no_match (keywordNoMatchField msgs model)
                        , Field meta.default_no_keyword_auto_reply (noKAutoReplyField msgs model)
                        , Field meta.default_no_keyword_not_live (noKNotLiveField msgs model)
                        ]
                    , FieldGroup { defaultFieldGroupConfig | header = Just "Contact Signup" }
                        [ Field meta.start_reply (startReplyField msgs model)
                        , Field meta.auto_name_request (autoNameField msgs model)
                        , Field meta.name_update_reply (nameUpdateField msgs model)
                        , Field meta.name_failure_reply (nameFailField msgs model)
                        ]
                    ]
            in
            Html.div []
                [ Html.p [] [ Html.text "These are the default replies used in various circumstances." ]
                , F.form
                    formStatus
                    fields
                    msgs.postForm
                    (F.submitButton (Just model))
                ]


keywordNoMatchField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
keywordNoMatchField msgs model =
    F.longTextField 10
        (Just model.keyword_no_match)
        (msgs.form << UpdateKeywordNoMatch)


noKAutoReplyField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
noKAutoReplyField msgs model =
    F.longTextField 10
        (Just model.default_no_keyword_auto_reply)
        (msgs.form << UpdateNoKeywordAutoReply)


noKNotLiveField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
noKNotLiveField msgs model =
    F.longTextField 10
        (Just model.default_no_keyword_not_live)
        (msgs.form << UpdateDefaultNoKeywordNotLive)


startReplyField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
startReplyField msgs model =
    F.longTextField 10
        (Just model.start_reply)
        (msgs.form << UpdateStartReply)


autoNameField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
autoNameField msgs model =
    F.longTextField 10
        (Just model.auto_name_request)
        (msgs.form << UpdateAutoName)


nameUpdateField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
nameUpdateField msgs model =
    F.longTextField 10
        (Just model.name_update_reply)
        (msgs.form << UpdateNameUpdateReply)


nameFailField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
nameFailField msgs model =
    F.longTextField 10
        (Just model.name_failure_reply)
        (msgs.form << UpdateNameFailReply)
