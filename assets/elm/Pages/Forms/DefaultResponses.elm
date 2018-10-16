module Pages.Forms.DefaultResponses exposing (Model, Msg(..), decodeDRModel, init, initialModel, update, view)

import DjangoSend
import Form as F exposing (defaultFieldGroupConfig)
import Helpers exposing (onClick, userFacingErrorMessage)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Pages.Forms.Meta.DefaultResponses exposing (meta)
import Urls


init : Cmd Msg
init =
    Http.get Urls.api_default_responses decodeDRModel
        |> Http.send ReceiveInitialData


type alias Model =
    { form : F.Form DRModel ()
    }


initialModel : Model
initialModel =
    { form = F.formLoading
    }


type alias DRModel =
    { keyword_no_match : String
    , default_no_keyword_auto_reply : String
    , default_no_keyword_not_live : String
    , start_reply : String
    , auto_name_request : String
    , name_update_reply : String
    , name_failure_reply : String
    }


decodeDRModel : Decode.Decoder DRModel
decodeDRModel =
    decode DRModel
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
    | ReceiveInitialData (Result Http.Error DRModel)


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
                { model | form = F.startUpdating initialModel () }
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
                (postCmd props.csrftoken model)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> DRModel -> () -> ( DRModel, () )
updateInput msg model _ =
    ( updateInputHelp msg model, () )


updateInputHelp : InputMsg -> DRModel -> DRModel
updateInputHelp msg model =
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


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    case F.getCurrent model.form of
        Just item ->
            DjangoSend.rawPost csrf Urls.api_default_responses (toBody item)
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none


toBody : DRModel -> List ( String, Encode.Value )
toBody model =
    [ ( "keyword_no_match", Encode.string model.keyword_no_match )
    , ( "default_no_keyword_auto_reply", Encode.string model.default_no_keyword_auto_reply )
    , ( "default_no_keyword_not_live", Encode.string model.default_no_keyword_not_live )
    , ( "start_reply", Encode.string model.start_reply )
    , ( "auto_name_request", Encode.string model.auto_name_request )
    , ( "name_update_reply", Encode.string model.name_update_reply )
    , ( "name_failure_reply", Encode.string model.name_failure_reply )
    ]



-- View


type alias Messages msg =
    { form : InputMsg -> msg
    , postForm : msg
    }


view : Messages msg -> Model -> Html msg
view msgs { form } =
    Html.div []
        [ Html.p [] [ Html.text "These are the default replies used in various circumstances." ]
        , F.form
            form
            (fieldsHelp msgs)
            msgs.postForm
            F.submitButton
        ]


fieldsHelp : Messages msg -> F.Item DRModel -> () -> List (F.FormItem msg)
fieldsHelp msgs item _ =
    [ F.FieldGroup { defaultFieldGroupConfig | header = Just "Keyword" }
        [ F.Field meta.keyword_no_match (keywordNoMatchField msgs item)
        , F.Field meta.default_no_keyword_auto_reply (noKAutoReplyField msgs item)
        , F.Field meta.default_no_keyword_not_live (noKNotLiveField msgs item)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "Contact Signup" }
        [ F.Field meta.start_reply (startReplyField msgs item)
        , F.Field meta.auto_name_request (autoNameField msgs item)
        , F.Field meta.name_update_reply (nameUpdateField msgs item)
        , F.Field meta.name_failure_reply (nameFailField msgs item)
        ]
    ]


keywordNoMatchField : Messages msg -> F.Item DRModel -> (F.FieldMeta -> List (Html msg))
keywordNoMatchField msgs item =
    F.longTextField 10
        { getValue = .keyword_no_match
        , item = item
        , onInput = msgs.form << UpdateKeywordNoMatch
        }


noKAutoReplyField : Messages msg -> F.Item DRModel -> (F.FieldMeta -> List (Html msg))
noKAutoReplyField msgs item =
    F.longTextField 10
        { getValue = .default_no_keyword_auto_reply
        , item = item
        , onInput = msgs.form << UpdateNoKeywordAutoReply
        }


noKNotLiveField : Messages msg -> F.Item DRModel -> (F.FieldMeta -> List (Html msg))
noKNotLiveField msgs item =
    F.longTextField 10
        { getValue = .default_no_keyword_auto_reply
        , item = item
        , onInput = msgs.form << UpdateDefaultNoKeywordNotLive
        }


startReplyField : Messages msg -> F.Item DRModel -> (F.FieldMeta -> List (Html msg))
startReplyField msgs item =
    F.longTextField 10
        { getValue = .start_reply
        , item = item
        , onInput = msgs.form << UpdateStartReply
        }


autoNameField : Messages msg -> F.Item DRModel -> (F.FieldMeta -> List (Html msg))
autoNameField msgs item =
    F.longTextField 10
        { getValue = .auto_name_request
        , item = item
        , onInput = msgs.form << UpdateAutoName
        }


nameUpdateField : Messages msg -> F.Item DRModel -> (F.FieldMeta -> List (Html msg))
nameUpdateField msgs item =
    F.longTextField 10
        { getValue = .name_update_reply
        , item = item
        , onInput = msgs.form << UpdateNameUpdateReply
        }


nameFailField : Messages msg -> F.Item DRModel -> (F.FieldMeta -> List (Html msg))
nameFailField msgs item =
    F.longTextField 10
        { getValue = .name_failure_reply
        , item = item
        , onInput = msgs.form << UpdateNameFailReply
        }
