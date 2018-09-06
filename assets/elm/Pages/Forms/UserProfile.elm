module Pages.Forms.UserProfile exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (UserProfile)
import DjangoSend
import Form as F exposing (..)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.UserProfile exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL
import Urls


type alias Model =
    { approved : Maybe Bool
    , message_cost_limit : Maybe Float
    , can_see_groups : Maybe Bool
    , can_see_contact_names : Maybe Bool
    , can_see_keywords : Maybe Bool
    , can_see_outgoing : Maybe Bool
    , can_see_incoming : Maybe Bool
    , can_send_sms : Maybe Bool
    , can_see_contact_nums : Maybe Bool
    , can_see_contact_notes : Maybe Bool
    , can_import : Maybe Bool
    , can_archive : Maybe Bool
    , formStatus : FormStatus
    }


initialModel : Model
initialModel =
    { approved = Nothing
    , message_cost_limit = Nothing
    , can_see_groups = Nothing
    , can_see_contact_names = Nothing
    , can_see_keywords = Nothing
    , can_see_outgoing = Nothing
    , can_see_incoming = Nothing
    , can_send_sms = Nothing
    , can_see_contact_nums = Nothing
    , can_see_contact_notes = Nothing
    , can_import = Nothing
    , can_archive = Nothing
    , formStatus = NoAction
    }



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type InputMsg
    = UpdateApproved (Maybe UserProfile)
    | UpdateMessageCostLimit String
    | UpdateCanSeeGroups (Maybe UserProfile)
    | UpdateCanSeeContactNames (Maybe UserProfile)
    | UpdateCanSeeKeywords (Maybe UserProfile)
    | UpdateCanSeeOutgoing (Maybe UserProfile)
    | UpdateCanSeeIncoming (Maybe UserProfile)
    | UpdateCanSendSms (Maybe UserProfile)
    | UpdateCanSeeContactNums (Maybe UserProfile)
    | UpdateCanSeeContactNotes (Maybe UserProfile)
    | UpdateCanImport (Maybe UserProfile)
    | UpdateCanArchive (Maybe UserProfile)


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    , userprofiles : RL.RemoteList UserProfile
    , userPk : Int
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

        PostForm ->
            F.UpdateResp
                model
                (postCmd
                    props.csrftoken
                    model
                    (RL.filter (\x -> x.user.pk == props.userPk) props.userprofiles
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
        UpdateApproved maybeProfile ->
            { model | approved = getNewBool model.approved (Maybe.map .approved maybeProfile) }

        UpdateCanSeeGroups maybeProfile ->
            { model | can_see_groups = getNewBool model.can_see_groups (Maybe.map .can_see_groups maybeProfile) }

        UpdateCanSeeContactNames maybeProfile ->
            { model | can_see_contact_names = getNewBool model.can_see_contact_names (Maybe.map .can_see_contact_names maybeProfile) }

        UpdateCanSeeKeywords maybeProfile ->
            { model | can_see_keywords = getNewBool model.can_see_keywords (Maybe.map .can_see_keywords maybeProfile) }

        UpdateCanSeeOutgoing maybeProfile ->
            { model | can_see_outgoing = getNewBool model.can_see_outgoing (Maybe.map .can_see_outgoing maybeProfile) }

        UpdateCanSeeIncoming maybeProfile ->
            { model | can_see_incoming = getNewBool model.can_see_incoming (Maybe.map .can_see_incoming maybeProfile) }

        UpdateCanSendSms maybeProfile ->
            { model | can_send_sms = getNewBool model.can_send_sms (Maybe.map .can_send_sms maybeProfile) }

        UpdateCanSeeContactNums maybeProfile ->
            { model | can_see_contact_nums = getNewBool model.can_see_contact_nums (Maybe.map .can_see_contact_nums maybeProfile) }

        UpdateCanSeeContactNotes maybeProfile ->
            { model | can_see_contact_notes = getNewBool model.can_see_contact_notes (Maybe.map .can_see_contact_nums maybeProfile) }

        UpdateCanImport maybeProfile ->
            { model | can_import = getNewBool model.can_import (Maybe.map .can_import maybeProfile) }

        UpdateCanArchive maybeProfile ->
            { model | can_archive = getNewBool model.can_archive (Maybe.map .can_archive maybeProfile) }

        UpdateMessageCostLimit text ->
            case String.toFloat text of
                Ok num ->
                    { model | message_cost_limit = Just num }

                Err _ ->
                    model


postCmd : DjangoSend.CSRFToken -> Model -> Maybe UserProfile -> Cmd Msg
postCmd csrf model maybeProfile =
    let
        body =
            [ ( "approved", Encode.bool <| F.extractBool .approved model.approved maybeProfile )
            , ( "message_cost_limit", Encode.float <| F.extractFloat .message_cost_limit model.message_cost_limit maybeProfile )
            , ( "can_see_groups", Encode.bool <| F.extractBool .can_see_groups model.can_see_groups maybeProfile )
            , ( "can_see_contact_names", Encode.bool <| F.extractBool .can_see_contact_names model.can_see_contact_names maybeProfile )
            , ( "can_see_keywords", Encode.bool <| F.extractBool .can_see_keywords model.can_see_keywords maybeProfile )
            , ( "can_see_outgoing", Encode.bool <| F.extractBool .can_see_outgoing model.can_see_outgoing maybeProfile )
            , ( "can_see_incoming", Encode.bool <| F.extractBool .can_see_incoming model.can_see_incoming maybeProfile )
            , ( "can_send_sms", Encode.bool <| F.extractBool .can_send_sms model.can_send_sms maybeProfile )
            , ( "can_see_contact_nums", Encode.bool <| F.extractBool .can_see_contact_nums model.can_see_contact_nums maybeProfile )
            , ( "can_see_contact_notes", Encode.bool <| F.extractBool .can_see_contact_notes model.can_see_contact_notes maybeProfile )
            , ( "can_import", Encode.bool <| F.extractBool .can_import model.can_import maybeProfile )
            , ( "can_archive", Encode.bool <| F.extractBool .can_archive model.can_archive maybeProfile )
            ]
                |> F.addPk maybeProfile
    in
    case maybeProfile of
        Nothing ->
            Cmd.none

        Just _ ->
            DjangoSend.rawPost csrf Urls.api_user_profiles body
                |> Http.send ReceiveFormResp


getNewBool : Maybe Bool -> Maybe Bool -> Maybe Bool
getNewBool modelVal profileVal =
    case modelVal of
        Just curVal ->
            -- we have edited the form, toggle the val
            Just <| not curVal

        Nothing ->
            -- we have not edited the form yet, toggle if we have a saved profile
            Maybe.map not profileVal



-- View


type alias Messages msg =
    { inputChange : InputMsg -> msg
    , postForm : msg
    }


view : Messages msg -> Int -> RL.RemoteList UserProfile -> Model -> Html msg
view msgs pk profiles_ model =
    let
        profiles =
            RL.toList profiles_

        currentProfile =
            profiles
                |> List.filter (\x -> x.user.pk == pk)
                |> List.head
    in
    case currentProfile of
        Nothing ->
            loader

        Just prof ->
            viewHelp msgs model.formStatus prof


viewHelp : Messages msg -> FormStatus -> UserProfile -> Html msg
viewHelp msgs status profile =
    let
        fields =
            [ Field meta.approved (approvedField msgs profile)
            , Field meta.message_cost_limit (simpleFloatField (Just profile.message_cost_limit) (msgs.inputChange << UpdateMessageCostLimit))
            , Field meta.can_see_groups (checkboxField (Just profile) .can_see_groups (msgs.inputChange << UpdateCanSeeGroups))
            , Field meta.can_see_contact_names (checkboxField (Just profile) .can_see_contact_names (msgs.inputChange << UpdateCanSeeContactNames))
            , Field meta.can_see_keywords (checkboxField (Just profile) .can_see_keywords (msgs.inputChange << UpdateCanSeeKeywords))
            , Field meta.can_see_outgoing (checkboxField (Just profile) .can_see_outgoing (msgs.inputChange << UpdateCanSeeOutgoing))
            , Field meta.can_see_incoming (checkboxField (Just profile) .can_see_incoming (msgs.inputChange << UpdateCanSeeIncoming))
            , Field meta.can_send_sms (checkboxField (Just profile) .can_send_sms (msgs.inputChange << UpdateCanSendSms))
            , Field meta.can_see_contact_nums (checkboxField (Just profile) .can_see_contact_nums (msgs.inputChange << UpdateCanSeeContactNums))
            , Field meta.can_see_contact_notes (checkboxField (Just profile) .can_see_contact_notes (msgs.inputChange << UpdateCanSeeContactNotes))
            , Field meta.can_import (checkboxField (Just profile) .can_import (msgs.inputChange << UpdateCanImport))
            , Field meta.can_archive (checkboxField (Just profile) .can_archive (msgs.inputChange << UpdateCanArchive))
            ]
                |> List.map FormField
    in
    Html.div []
        [ Html.h3 [ Css.max_w_md, Css.mx_auto ] [ Html.text <| "User Profile: " ++ profile.user.email ]
        , form status
            fields
            msgs.postForm
            (submitButton (Just profile))
        ]


approvedField : Messages msg -> UserProfile -> FieldMeta -> List (Html msg)
approvedField msgs profile fieldMeta =
    checkboxField
        (Just profile)
        .approved
        (msgs.inputChange << UpdateApproved)
        fieldMeta
