module Pages.Forms.DefaultResponses exposing (Model, Msg(..), decodeModel, init, update, view)

import Forms.Model exposing (Field, FieldMeta, FormItem(FieldGroup), FormStatus, defaultFieldGroupConfig)
import Forms.View as FV
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Pages.Forms.Meta.DefaultResponses exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Urls


init : Cmd Msg
init =
    Http.get Urls.api_default_responses decodeModel
        |> Http.send ReceiveInitialData


type alias Model =
    { keyword_no_match : String
    , default_no_keyword_auto_reply : String
    , default_no_keyword_not_live : String
    , start_reply : String
    , auto_name_request : String
    , name_update_reply : String
    , name_failure_reply : String
    }


decodeModel : Decode.Decoder Model
decodeModel =
    decode Model
        |> required "keyword_no_match" Decode.string
        |> required "default_no_keyword_auto_reply" Decode.string
        |> required "default_no_keyword_not_live" Decode.string
        |> required "start_reply" Decode.string
        |> required "auto_name_request" Decode.string
        |> required "name_update_reply" Decode.string
        |> required "name_failure_reply" Decode.string



-- Update


type Msg
    = UpdateKeywordNoMatch String
    | UpdateNoKeywordAutoReply String
    | UpdateDefaultNoKeywordNotLive String
    | UpdateStartReply String
    | UpdateAutoName String
    | UpdateNameUpdateReply String
    | UpdateNameFailReply String
    | ReceiveInitialData (Result Http.Error Model)


update : Msg -> Maybe Model -> Maybe Model
update msg maybeModel =
    case ( msg, maybeModel ) of
        ( UpdateKeywordNoMatch text, Just model ) ->
            Just { model | keyword_no_match = text }

        ( UpdateNoKeywordAutoReply text, Just model ) ->
            Just { model | default_no_keyword_auto_reply = text }

        ( UpdateDefaultNoKeywordNotLive text, Just model ) ->
            Just { model | default_no_keyword_not_live = text }

        ( UpdateStartReply text, Just model ) ->
            Just { model | start_reply = text }

        ( UpdateAutoName text, Just model ) ->
            Just { model | auto_name_request = text }

        ( UpdateNameUpdateReply text, Just model ) ->
            Just { model | name_update_reply = text }

        ( UpdateNameFailReply text, Just model ) ->
            Just { model | name_failure_reply = text }

        ( ReceiveInitialData (Ok initialModel), _ ) ->
            Just initialModel

        ( ReceiveInitialData (Err _), _ ) ->
            Nothing

        ( _, Nothing ) ->
            Nothing



-- View


type alias Messages msg =
    { form : Msg -> msg
    , postForm : msg
    }


view : Messages msg -> Maybe Model -> FormStatus -> Html msg
view msgs maybeModel status =
    case maybeModel of
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
                , FV.form status
                    fields
                    msgs.postForm
                    (FV.submitButton (Just model))
                ]


keywordNoMatchField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
keywordNoMatchField msgs model =
    FV.longTextField 10
        (Just model.keyword_no_match)
        (msgs.form << UpdateKeywordNoMatch)


noKAutoReplyField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
noKAutoReplyField msgs model =
    FV.longTextField 10
        (Just model.default_no_keyword_auto_reply)
        (msgs.form << UpdateNoKeywordAutoReply)


noKNotLiveField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
noKNotLiveField msgs model =
    FV.longTextField 10
        (Just model.default_no_keyword_not_live)
        (msgs.form << UpdateDefaultNoKeywordNotLive)


startReplyField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
startReplyField msgs model =
    FV.longTextField 10
        (Just model.start_reply)
        (msgs.form << UpdateStartReply)


autoNameField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
autoNameField msgs model =
    FV.longTextField 10
        (Just model.auto_name_request)
        (msgs.form << UpdateAutoName)


nameUpdateField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
nameUpdateField msgs model =
    FV.longTextField 10
        (Just model.name_update_reply)
        (msgs.form << UpdateNameUpdateReply)


nameFailField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
nameFailField msgs model =
    FV.longTextField 10
        (Just model.name_failure_reply)
        (msgs.form << UpdateNameFailReply)
