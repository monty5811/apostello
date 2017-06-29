module Pages.Forms.DefaultResponses.View exposing (view)

import DjangoSend exposing (CSRFToken)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View as FV
import Html exposing (Html)
import Html.Attributes as A
import Messages exposing (FormMsg(DefaultResponsesFormMsg, PostForm), Msg(FormMsg))
import Pages.Forms.DefaultResponses.Messages exposing (DefaultResponsesFormMsg(..))
import Pages.Forms.DefaultResponses.Meta exposing (meta)
import Pages.Forms.DefaultResponses.Model exposing (DefaultResponsesFormModel)
import Pages.Forms.DefaultResponses.Remote exposing (postCmd)
import Pages.Fragments.Loader exposing (loader)


view : CSRFToken -> Maybe DefaultResponsesFormModel -> FormStatus -> Html Msg
view csrf maybeModel status =
    case maybeModel of
        Nothing ->
            loader

        Just model ->
            let
                fields =
                    [ Field meta.keyword_no_match (keywordNoMatchField meta.keyword_no_match model)
                    , Field meta.default_no_keyword_auto_reply (noKAutoReplyField meta.default_no_keyword_auto_reply model)
                    , Field meta.default_no_keyword_not_live (noKNotLiveField meta.default_no_keyword_not_live model)
                    , Field meta.start_reply (startReplyField meta.start_reply model)
                    , Field meta.auto_name_request (autoNameField meta.auto_name_request model)
                    , Field meta.name_update_reply (nameUpdateField meta.name_update_reply model)
                    , Field meta.name_failure_reply (nameFailField meta.name_failure_reply model)
                    ]
            in
            Html.div []
                [ Html.p [] [ Html.text "These are the default replies used in various circumstances." ]
                , FV.form status
                    fields
                    (FormMsg <| PostForm <| postCmd csrf model)
                    (FV.submitButton (Just model) False)
                ]


keywordNoMatchField : FieldMeta -> DefaultResponsesFormModel -> List (Html Msg)
keywordNoMatchField meta_ model =
    let
        updater text =
            { model | keyword_no_match = text }
    in
    FV.longTextField 10
        meta_
        (Just model.keyword_no_match)
        (FormMsg << DefaultResponsesFormMsg << UpdateField updater)


noKAutoReplyField : FieldMeta -> DefaultResponsesFormModel -> List (Html Msg)
noKAutoReplyField meta_ model =
    let
        updater text =
            { model | default_no_keyword_auto_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.default_no_keyword_auto_reply)
        (FormMsg << DefaultResponsesFormMsg << UpdateField updater)


noKNotLiveField : FieldMeta -> DefaultResponsesFormModel -> List (Html Msg)
noKNotLiveField meta_ model =
    let
        updater text =
            { model | default_no_keyword_not_live = text }
    in
    FV.longTextField 10
        meta_
        (Just model.default_no_keyword_not_live)
        (FormMsg << DefaultResponsesFormMsg << UpdateField updater)


startReplyField : FieldMeta -> DefaultResponsesFormModel -> List (Html Msg)
startReplyField meta_ model =
    let
        updater text =
            { model | start_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.start_reply)
        (FormMsg << DefaultResponsesFormMsg << UpdateField updater)


autoNameField : FieldMeta -> DefaultResponsesFormModel -> List (Html Msg)
autoNameField meta_ model =
    let
        updater text =
            { model | auto_name_request = text }
    in
    FV.longTextField 10
        meta_
        (Just model.auto_name_request)
        (FormMsg << DefaultResponsesFormMsg << UpdateField updater)


nameUpdateField : FieldMeta -> DefaultResponsesFormModel -> List (Html Msg)
nameUpdateField meta_ model =
    let
        updater text =
            { model | name_update_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.name_update_reply)
        (FormMsg << DefaultResponsesFormMsg << UpdateField updater)


nameFailField : FieldMeta -> DefaultResponsesFormModel -> List (Html Msg)
nameFailField meta_ model =
    let
        updater text =
            { model | name_failure_reply = text }
    in
    FV.longTextField 10
        meta_
        (Just model.name_failure_reply)
        (FormMsg << DefaultResponsesFormMsg << UpdateField updater)
