module Pages.Forms.DefaultResponses exposing (Model, Msg(..), decodeModel, update, view)

import Forms.Model exposing (Field, FieldMeta, FormItem(FieldGroup), FormStatus, defaultFieldGroupConfig)
import Forms.View as FV
import Html exposing (Html)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Pages.Forms.Meta.DefaultResponses exposing (meta)
import Pages.Fragments.Loader exposing (loader)


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
    = UpdateField (String -> Model) String


update : Msg -> Model
update msg =
    case msg of
        UpdateField updater text ->
            updater text



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
                        [ Field meta.keyword_no_match (keywordNoMatchField msgs meta.keyword_no_match model)
                        , Field meta.default_no_keyword_auto_reply (noKAutoReplyField msgs meta.default_no_keyword_auto_reply model)
                        , Field meta.default_no_keyword_not_live (noKNotLiveField msgs meta.default_no_keyword_not_live model)
                        ]
                    , FieldGroup { defaultFieldGroupConfig | header = Just "Contact Signup" }
                        [ Field meta.start_reply (startReplyField msgs meta.start_reply model)
                        , Field meta.auto_name_request (autoNameField msgs meta.auto_name_request model)
                        , Field meta.name_update_reply (nameUpdateField msgs meta.name_update_reply model)
                        , Field meta.name_failure_reply (nameFailField msgs meta.name_failure_reply model)
                        ]
                    ]
            in
            Html.div []
                [ Html.p [] [ Html.text "These are the default replies used in various circumstances." ]
                , FV.form status
                    fields
                    msgs.postForm
                    (FV.submitButton (Just model) False)
                ]


keywordNoMatchField : Messages msg -> FieldMeta -> Model -> List (Html msg)
keywordNoMatchField msgs meta_ model =
    let
        updater text =
            { model | keyword_no_match = text }
    in
    FV.longTextField 10
        meta_
        (Just model.keyword_no_match)
        (msgs.form << UpdateField updater)


noKAutoReplyField : Messages msg -> FieldMeta -> Model -> List (Html msg)
noKAutoReplyField msgs meta_ model =
    let
        updater text =
            { model | default_no_keyword_auto_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.default_no_keyword_auto_reply)
        (msgs.form << UpdateField updater)


noKNotLiveField : Messages msg -> FieldMeta -> Model -> List (Html msg)
noKNotLiveField msgs meta_ model =
    let
        updater text =
            { model | default_no_keyword_not_live = text }
    in
    FV.longTextField 10
        meta_
        (Just model.default_no_keyword_not_live)
        (msgs.form << UpdateField updater)


startReplyField : Messages msg -> FieldMeta -> Model -> List (Html msg)
startReplyField msgs meta_ model =
    let
        updater text =
            { model | start_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.start_reply)
        (msgs.form << UpdateField updater)


autoNameField : Messages msg -> FieldMeta -> Model -> List (Html msg)
autoNameField msgs meta_ model =
    let
        updater text =
            { model | auto_name_request = text }
    in
    FV.longTextField 10
        meta_
        (Just model.auto_name_request)
        (msgs.form << UpdateField updater)


nameUpdateField : Messages msg -> FieldMeta -> Model -> List (Html msg)
nameUpdateField msgs meta_ model =
    let
        updater text =
            { model | name_update_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.name_update_reply)
        (msgs.form << UpdateField updater)


nameFailField : Messages msg -> FieldMeta -> Model -> List (Html msg)
nameFailField msgs meta_ model =
    let
        updater text =
            { model | name_failure_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.name_failure_reply)
        (msgs.form << UpdateField updater)
