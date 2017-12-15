module Pages.Forms.UserProfile exposing (Model, Msg, initialModel, update, view)

import Data exposing (UserProfile)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (..)
import Html exposing (Html)
import Pages.Forms.Meta.UserProfile exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL


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
    }



-- Update


type Msg
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


update : Msg -> Model -> Model
update msg model =
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


getNewBool : Maybe Bool -> Maybe Bool -> Maybe Bool
getNewBool modelVal profileVal =
    case modelVal of
        Just curVal ->
            -- we haev edited the form, toggle the val
            Just <| not curVal

        Nothing ->
            -- we have not edited the form yet, toggle if we have a saved profile
            Maybe.map not profileVal



-- View


type alias Messages msg =
    { form : Msg -> msg
    , postForm : msg
    }


view : Messages msg -> Int -> RL.RemoteList UserProfile -> Model -> FormStatus -> Html msg
view msgs pk profiles_ model status =
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
            viewHelp msgs model status prof


viewHelp : Messages msg -> Model -> FormStatus -> UserProfile -> Html msg
viewHelp msgs model status profile =
    let
        fields =
            [ Field meta.approved (approvedField msgs profile)
            , Field meta.message_cost_limit (simpleFloatField (Just profile.message_cost_limit) (msgs.form << UpdateMessageCostLimit))
            , Field meta.can_see_groups (checkboxField (Just profile) .can_see_groups (msgs.form << UpdateCanSeeGroups))
            , Field meta.can_see_contact_names (checkboxField (Just profile) .can_see_contact_names (msgs.form << UpdateCanSeeContactNames))
            , Field meta.can_see_keywords (checkboxField (Just profile) .can_see_keywords (msgs.form << UpdateCanSeeKeywords))
            , Field meta.can_see_outgoing (checkboxField (Just profile) .can_see_outgoing (msgs.form << UpdateCanSeeOutgoing))
            , Field meta.can_see_incoming (checkboxField (Just profile) .can_see_incoming (msgs.form << UpdateCanSeeIncoming))
            , Field meta.can_send_sms (checkboxField (Just profile) .can_send_sms (msgs.form << UpdateCanSendSms))
            , Field meta.can_see_contact_nums (checkboxField (Just profile) .can_see_contact_nums (msgs.form << UpdateCanSeeContactNums))
            , Field meta.can_see_contact_notes (checkboxField (Just profile) .can_see_contact_notes (msgs.form << UpdateCanSeeContactNotes))
            , Field meta.can_import (checkboxField (Just profile) .can_import (msgs.form << UpdateCanImport))
            , Field meta.can_archive (checkboxField (Just profile) .can_archive (msgs.form << UpdateCanArchive))
            ]
                |> List.map FormField
    in
    Html.div []
        [ Html.h3 [] [ Html.text <| "User Profile: " ++ profile.user.email ]
        , form status
            fields
            msgs.postForm
            (submitButton (Just profile) False)
        ]


approvedField : Messages msg -> UserProfile -> FieldMeta -> List (Html msg)
approvedField msgs profile fieldMeta =
    checkboxField
        (Just profile)
        .approved
        (msgs.form << UpdateApproved)
        fieldMeta
